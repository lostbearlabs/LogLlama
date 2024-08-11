import Foundation

/// This is a wrapper around Regex to encapsulate the specific ways its used in LogLlama.  This wrapper exists to encourage unit testing of
/// code that might otherwise be in the middle of other methods and to reduce repetition.
class RegexWithGroups {

  var regex: Regex<AnyRegexOutput>
  var pattern: String

  init(pattern: String) throws {
    self.pattern = pattern
    self.regex = try Regex(pattern)
  }

  func hasMatch(text: String) -> Bool {
    let matches = text.matches(of: regex)
    return !matches.isEmpty
  }

  func hasWholeMatch(text: String) -> Bool {
    return text.wholeMatch(of: regex) != nil
  }

  /**
     If the regex matches the text, returns all the named captures in the match.
     (Unnamed captures are ignored.)
     */
  func captures(text: String) -> [[String: String]] {
    var captures = [[String: String]]()
    let matches = text.matches(of: regex)
    for match in matches {
      let output = match.output
      var map = [String: String]()
      for capture in output {
        let key = capture.name
        let range = capture.range
        if key != nil && range != nil {
          let value = String(text[range!])
          map[key!] = value
        }
      }
      if !map.isEmpty {
        captures.append(map)
      }
    }

    return captures
  }

  /**
     If the regex matches the text, returns all the matching ranges
     */
  func ranges(text: String) -> [Range<String.Index>] {
    var ranges = [Range<String.Index>]()
    let matches = text.matches(of: regex)
    for match in matches {
      let output = match.output
      for i in 0...output.count - 1 {
        let group = output[i]
        if let range = group.range {
          ranges.append(range)
        }
      }
    }

    return ranges

  }

  /**
     Gets all the group names defined in the regex.
     */
  func groupNames() -> [String] {
    var names = [String]()
    do {
      let rx = try Regex("\\(\\?\\<(\\w+)\\>")
      let matches = self.pattern.matches(of: rx)
      for match in matches {
        let output = match.output
        for i in 1...output.count - 1 {
          let group = output[i]
          if let range = group.range {
            let name = String(self.pattern[range])
            names.append(name)
          }
        }
      }
    } catch {
      //
    }
    return names
  }

}
