import AppKit
import Foundation

/// Applies a regular expression to LogLines, coloring and filtering them depending whether they match.
///
/// If the regex has named groups, then the values of those groups will be set as fields on the matched lines.
///
/// This command implements all 4 of our filtering operations.
class FilterLineCommand: ScriptCommand {

  enum FilterType {
    case Required
    case Add
    case Remove
    case Highlight
  }

  var callback: ScriptCallback
  var filterType: FilterType
  var pattern: String
  var regex: RegexWithGroups?
  var groupNames: [String]?

  init(callback: ScriptCallback, pattern: String, filterType: FilterType) {
    self.callback = callback
    self.pattern = pattern
    self.filterType = filterType
  }

  func validate() -> Bool {
    do {
      // parse the regex for efficient use later
      try self.regex = RegexWithGroups(pattern: self.pattern)
      self.groupNames = self.regex!.groupNames()

      return true
    } catch {
      self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
      return false
    }
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {

    self.callback.scriptUpdate(text: "Applying regular expression: \(self.pattern)")
    self.callback.scriptUpdate(text: "... field names: \(self.groupNames!.sorted())")

    var n = 0
    DispatchQueue.concurrentPerform(iterations: logLines.count) { (index) in

      let line = logLines[index]
      let results = regex!.ranges(text: line.text)

      // hilight any matching parts of the line
      if results.count > 0 {
        n += 1

        let _ = results.map {
          let match = $0
          let nsRange = line.text.toNSRange(from: match)

          // add hilite color to display text
          line.attributed.addAttribute(.backgroundColor, value: runState.color, range: nsRange)
        }
      }

      var keys = [String: String]()
      let captures = regex!.captures(text: line.text)
      for capture in captures {
        for key in capture.keys {
          line.namedFieldValues[key] = capture[key]
          keys[key] = key
        }
      }

      let match = !results.isEmpty
      switch self.filterType {

      case .Required:
        line.visible = line.visible && match
        line.matched = line.matched || match
      case .Add:
        line.visible = line.visible || match
        line.matched = line.matched || match
      case .Remove:
        if !line.beginSection {  // it's confusing if we hide section headers
          line.visible = line.visible && !match
          line.matched = line.matched && !match
        }
      case .Highlight:
        line.matched = line.matched || match
      }

    }

    self.callback.scriptUpdate(text: "... \(n) line(s) matched")

    return true
  }

  func description() -> String {
    switch self.filterType {
    case .Required:
      return "="
    case .Add:
      return "+"
    case .Remove:
      return "-"
    case .Highlight:
      return "~"
    }
  }

}

extension String {
  func toNSRange(from range: Range<String.Index>) -> NSRange {
    let location = range.lowerBound.utf16Offset(in: self)
    let length = range.upperBound.utf16Offset(in: self) - location
    return NSRange(location: location, length: length)
  }
}
