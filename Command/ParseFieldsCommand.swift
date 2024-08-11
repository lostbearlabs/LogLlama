import AppKit
import Foundation

/// Applies a regular expression with groups 'key' and 'value' to logLines, extracting field/value pairs for each line.
class ParseFieldsCommand: ScriptCommand {

  var callback: ScriptCallback
  var pattern: String
  var regex: RegexWithGroups?

  init(callback: ScriptCallback, pattern: String) {
    self.callback = callback
    self.pattern = pattern
  }

  func validate() -> Bool {
    do {
      // parse the regex for efficient use later
      try self.regex = RegexWithGroups(pattern: self.pattern)
      let groupNames = self.regex!.groupNames()

      if groupNames.count != 2 || groupNames[0] != "key" || groupNames[1] != "value" {
        self.callback.scriptUpdate(
          text: "regular expression does not have groups 'key' and 'value': \(self.pattern)")
        return false
      }

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

    self.callback.scriptUpdate(text: "Applying key/value expression: \(self.pattern)")

    if let regex {
      logLines.parseFields(regex: regex)
      self.callback.scriptUpdate(text: "... \(logLines.count) line(s) processed")
      return true
    } else {
      self.callback.scriptUpdate(text: "... regex not set")
      return false
    }

  }

  func description() -> String {
    return "kv"
  }

}
