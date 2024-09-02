import AppKit
import Foundation

/// Applies a regular expression to LogLines, coloring and filtering them depending whether they match.
///
/// If the regex has named groups, then the values of those groups will be set as fields on the matched lines.
///
/// This command implements all 4 of our filtering operations.
class FilterLineCommand: ScriptCommand {

  var callback: ScriptCallback?
  var filterType: FilterType = FilterType.highlight
  var pattern: String = ""
  var regex: RegexWithGroups?
  var groupNames: [String]?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {

    do {
      // parse the regex for efficient use later
      try self.regex = RegexWithGroups(pattern: self.pattern)
      self.groupNames = self.regex!.groupNames()

      return true
    } catch {
      log("invalid regular expression: \(self.pattern)")
      return false
    }
  }

  func getFilterType(line: ScriptLine) -> FilterType? {
    switch line.op() {
    case "=":
      return FilterType.required
    case "+":
      return FilterType.add
    case "-":
      return FilterType.remove
    case "~":
      return FilterType.highlight
    case "today":
      return FilterType.today
    default:
      return nil
    }
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback

    if let filterType = getFilterType(line: line) {
      self.filterType = filterType
      if filterType == .today {
        return setupToday(callback: callback, line: line)
      } else {
        return setupFilter(callback: callback, line: line)
      }
    } else {
      log("unexpected nil getting filter type")
      return false
    }
  }

  func setupToday(callback: ScriptCallback, line: ScriptLine) -> Bool {
    if line.done() {
      // We'll set the pattern at runtime instead of setup so we get the latest
      // date format from the run state.
      self.pattern = ""
      return true
    } else {
      log("expected 0 arguments")
      return false
    }
  }

  func setupFilter(callback: ScriptCallback, line: ScriptLine) -> Bool {
    if let pattern = line.rest(), line.done() {
      self.pattern = pattern
      do {
        try regex = RegexWithGroups(pattern: pattern)
        self.groupNames = regex?.groupNames()
        return true
      } catch {
        log("invalid regular expression: \(pattern)")
        return false
      }
    } else {
      log("expected 1 argument, filter type")
      return false
    }
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {

    if filterType == .today {
      if !setupToday(runState: runState) {
        return false
      }
    }

    log("Applying regular expression: \(self.pattern)")
    log("... field names: \(self.groupNames!.sorted())")

    if let regex {
      let n = logLines.applyFilter(
        regexFromFilter: regex, filterType: filterType, color: runState.color)
      log("... \(n) line(s) matched")
      return true
    } else {
      log("... regex not defined")
      return false
    }
  }

  func setupToday(runState: RunState) -> Bool {
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = runState.dateFormat
    self.pattern = formatter.string(from: now)

    do {
      try self.regex = RegexWithGroups(pattern: self.pattern)
      return true
    } catch {
      log("invalid regular expression: \(self.pattern)")
      return false
    }
  }

  func undoText() -> String {
    switch filterType {
    case .required:
      return "="
    case .add:
      return "+"
    case .remove:
      return "-"
    case .highlight:
      return "~"
    case .today:
      return "today"
    }
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .filter,
        op: "=",
        args: "regex",
        description: "hide all lines not matching regex"
      ),
      ScriptCommandDescription(
        category: .filter,
        op: "+",
        args: "regex",
        description: "unhide all lines matching regex"
      ),
      ScriptCommandDescription(
        category: .filter,
        op: "-",
        args: "regex",
        description: "hide all lines matching regex"
      ),
      ScriptCommandDescription(
        category: .filter,
        op: "~",
        args: "regex",
        description: "hilight regex without changing which lines are hidden"
      ),
      ScriptCommandDescription(
        category: .filter,
        op: "today",
        args: "",
        description: "when loading lines, filter out any that don't contain the current date"
      ),
    ]
  }

}

extension String {
  func toNSRange(from range: Range<String.Index>) -> NSRange {
    let location = range.lowerBound.utf16Offset(in: self)
    let length = range.upperBound.utf16Offset(in: self) - location
    return NSRange(location: location, length: length)
  }
}
