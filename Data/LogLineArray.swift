import AppKit
import Foundation

/// Encapsulates a list of LogLine objects, such as we display on the screen or keep in our undo buffer.
///
/// For ease of testing, logic for various commands that update the lines is also implemented on this class instead of
/// in the individual command classes.
class LogLineArray: Sequence {
  var lines: [LogLine] = []

  subscript(index: Int) -> LogLine {
    get {
      return lines[index]
    }
  }

  func makeIterator() -> IndexingIterator<[LogLine]> {
    return lines.makeIterator()
  }

  func append(_ line: LogLine) {
    lines.append(line)
  }

  var count: Int {
    return lines.count
  }

  func clear() {
    lines.removeAll()
  }

  func clone() -> LogLineArray {
    let other = LogLineArray()
    for line in lines {
      other.append(line.clone())
    }
    return other
  }

  /// Implementation for ChopCommand.
  func chop() {
    lines.removeAll(where: { !$0.visible })
  }

  /// Applies the provided operation to each log line.
  /// Returns the number of lines for which the operation returned true.
  private func forEachLine(_ op: (LogLine) -> Bool) -> Int {
    let n = AtomicCounter()
    DispatchQueue.concurrentPerform(iterations: lines.count) { (index) in
      let line = lines[index]
      if op(line) {
        n.increment()
      }
    }

    return n.get()
  }

  private func forEachPair(_ op: (LogLine, LogLine) -> Bool) -> Int {
    let n = AtomicCounter()
    DispatchQueue.concurrentPerform(iterations: lines.count) { (index) in
      if index > 0 {
        let prev = lines[index - 1]
        let line = lines[index]
        if op(prev, line) {
          n.increment()
        }
      }
    }

    return n.get()
  }

  /// Implementation for FilterLineCommand
  func applyFilter(regex: RegexWithGroups, filterType: FilterType, color: NSColor) -> Int {
    let n = forEachLine({ line in
      return self.applyFilterToLine(line: line, regex: regex, filterType: filterType, color: color)
    })
    return n
  }

  private func applyFilterToLine(
    line: LogLine, regex: RegexWithGroups, filterType: FilterType, color: NSColor
  ) -> Bool {
    let results = regex.ranges(text: line.text)
    let match = !results.isEmpty

    // hilight any matching parts of the line
    if match {
      let _ = results.map {
        let match = $0
        let nsRange = line.text.toNSRange(from: match)

        // add hilite color to display text
        line.attributed.addAttribute(.backgroundColor, value: color, range: nsRange)
      }
    }

    // set field values based on any named capture groups in the regex
    var keys = [String: String]()
    let captures = regex.captures(text: line.text)
    for capture in captures {
      for key in capture.keys {
        line.namedFieldValues[key] = capture[key]
        keys[key] = key
      }
    }

    // update visibility for the line
    switch filterType {

    case .today:
      line.visible = line.visible && match
      line.matched = line.matched || match
    case .required:
      line.visible = line.visible && match
      line.matched = line.matched || match
    case .add:
      line.visible = line.visible || match
      line.matched = line.matched || match
    case .remove:
      if !line.beginSection {  // it's confusing if we hide section headers
        line.visible = line.visible && !match
        line.matched = line.matched && !match
      }
    case .highlight:
      line.matched = line.matched || match
    }

    return match
  }

  /// Implementation for ParseFieldsCommand
  func parseFields(regex: RegexWithGroups) {
    _ = forEachLine { line in
      findNameValueFields(logLine: line, regex: regex)
      return true
    }
  }

  /// Implementation for RequireHilightCommand
  /// - Returns the number of lines hidden
  func hideNotHilighted() -> Int {
    return forEachLine { line in
      if line.visible && !line.matched {
        line.visible = false
        return true
      }
      return false
    }
  }

  /// Implementation for DivideByRegexCommand
  /// - Returns the number of section headers found
  func divideByRegex(regex: RegexWithGroups, color: NSColor) -> Int {
    return forEachLine { line in
      if regex.hasMatch(text: line.text) {
        line.setBeginSection(color: color)
        return true
      } else {
        return false
      }
    }
  }

  func divideByField(field: String, color: NSColor) -> Int {

    // Process adjacent lines concurrently.
    // (Safe as long as we're just reading fields and writing the section flag.  Would not be
    // safe if we were reading and updating the same data.)
    var n = forEachPair { prev, line in
      let prevVal = prev.namedFieldValues[field]
      let val = line.namedFieldValues[field]
      if val != prevVal {
        line.setBeginSection(color: color)
        return true
      }
      return false
    }

    // Special case:  if lines[0] has the field, treat that as a change from the implicit nil before it
    if count > 0 {
      let line0 = lines[0]
      if line0.namedFieldValues.keys.contains(field) {
        line0.setBeginSection(color: color)
        n += 1
      }
    }

    return n
  }

  /// Implementation for AddFieldCommand.
  ///
  /// This is a somewhat odd command, intended for use with log files that have a consistent field mapping but sometimes display one value and sometimes
  /// the other.  For example, if the log has "serverId=1, serverName=central" then this command could be used to ensure that every line with serverId=1 als
  /// gets serverName=central, or vice versa.
  ///
  /// We assume the mapping itself is uniqe.  If it's not, then our behavior is undefined.
  func addField(fieldToAdd: String, fieldToMatch: String) -> Int {
    let map = AtomicMap()

    // Get the mapping from values in fieldToMatch to values in FieldToMatch.
    _ = forEachLine { line in
      if line.namedFieldValues.keys.contains(fieldToAdd)
        && line.namedFieldValues.keys.contains(fieldToMatch)
      {
        let key = line.namedFieldValues[fieldToMatch]!
        let val = line.namedFieldValues[fieldToAdd]!
        map.set(value: val, forKey: key)
      }
      return true
    }

    // Now find any lines that are missing a mapped value, and populate them using the
    // mapping we discovered on other lines.
    return forEachLine { line in
      if !line.namedFieldValues.keys.contains(fieldToAdd)
        && line.namedFieldValues.keys.contains(fieldToMatch)
      {
        let key = fieldToAdd
        let match = line.namedFieldValues[fieldToMatch]!
        if let val = map.get(match) {
          line.namedFieldValues.updateValue(val, forKey: key)
          return true
        }
      }
      return false
    }
  }

  func filterSection(
    regex: RegexWithGroups, numVisible: inout Int, numHidden: inout Int, filterType: FilterType
  ) {
    var section: [LogLine] = []
    numHidden = 0
    numVisible = 0

    for line in lines {
      if !section.isEmpty && line.beginSection {
        self.processSection(
          section: section, regex: regex, numVisible: &numVisible, numHidden: &numHidden,
          filterType: filterType)
        section.removeAll()
      }
      section.append(line)
    }
    self.processSection(
      section: section, regex: regex, numVisible: &numVisible, numHidden: &numHidden,
      filterType: filterType)

  }

  private func processSection(
    section: [LogLine], regex: RegexWithGroups,
    numVisible: inout Int, numHidden: inout Int, filterType: FilterType
  ) {
    if !section.isEmpty {
      if self.keepVisible(section: section, regex: regex, filterType: filterType) {
        if section[0].visible {
          numVisible += 1
        }
      } else {
        for ln in section {
          ln.visible = false
        }
        numHidden += 1
      }
    }
  }

  private func keepVisible(section: [LogLine], regex: RegexWithGroups, filterType: FilterType)
    -> Bool
  {

    var match = false
    for line in section {
      if regex.hasMatch(text: line.text) {
        match = true
      }
    }

    switch filterType {
    case .today:
      return match
    case .required:
      return match
    case .remove:
      return !match
    case .add:
      return true
    case .highlight:
      return true
    }

  }

  /// Implementation for SortByFieldsCommand
  func sortByFields(fieldNames: [String]) {
    lines.sort(by: {
      let line1 = $0
      let line2 = $1

      for field in fieldNames {
        let val1 = $0.namedFieldValues[field]
        let val2 = $1.namedFieldValues[field]
        if val1 != val2 {
          if val1 == nil {
            if val2 != nil {
              // only val2 is set;  line2 comes first
              return false
            }
          } else {
            if val2 == nil {
              // only val1 is set;  line1 comes first
              return true
            } else {
              // val1 and val2 are set; compare them
              return val1! < val2!
            }
          }
        }
      }

      // as a last resort, compare the line numbers of the lines
      return line1.lineNumber < line2.lineNumber
    })

  }

  private func findNameValueFields(logLine: LogLine, regex: RegexWithGroups) {
    let text = logLine.text
    let captures = regex.captures(text: text)
    for capture in captures {
      let key = capture["key"]
      let value = capture["value"]
      if let key, let value {
        logLine.namedFieldValues[key] = value
      }
    }
  }

}
