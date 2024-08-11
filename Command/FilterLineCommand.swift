import AppKit
import Foundation

/// Applies a regular expression to LogLines, coloring and filtering them depending whether they match.
///
/// If the regex has named groups, then the values of those groups will be set as fields on the matched lines.
///
/// This command implements all 4 of our filtering operations.
class FilterLineCommand: ScriptCommand {

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

    if let regex {
      let n = logLines.applyFilter(regex: regex, filterType: filterType, color: runState.color)
      self.callback.scriptUpdate(text: "... \(n) line(s) matched")
      return true
    } else {
      self.callback.scriptUpdate(text: "... regex not defined")
      return false
    }
  }

  func description() -> String {
    switch self.filterType {
    case .required:
      return "="
    case .add:
      return "+"
    case .remove:
      return "-"
    case .highlight:
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
