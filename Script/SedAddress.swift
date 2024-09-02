import Foundation

/// A sed-style address, indicating which lines should be processed.
class SedAddress {
  var regex: RegexWithGroups?
  var range: (Int, Int)?

  init() {
  }

  init(regex: RegexWithGroups) {
    self.regex = regex
  }

  init(range: (Int, Int)) {
    self.range = range
  }

  /// Does this line match the address?
  func matches(line: LogLine) -> Bool {
    return lineRangeMatches(line: line) && patternMatches(line: line)
  }

  func lineRangeMatches(line: LogLine) -> Bool {
    if let range {
      if line.lineNumber < range.0 || line.lineNumber > range.1 {
        return false
      }
    }

    return true
  }

  func patternMatches(line: LogLine) -> Bool {
    if let regex {
      if !regex.hasMatch(text: line.text) {
        return false
      }
    }

    return true
  }

}
