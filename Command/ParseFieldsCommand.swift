import AppKit
import Foundation

/// Applies a regular expression with groups 'key' and 'value' to logLines, extracting field/value pairs for each line.
class ParseFieldsCommand: ScriptCommand {
  
  var callback: ScriptCallback?
  var pattern: String = ""
  var regex: RegexWithGroups?
  
  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {
    do {
      // parse the regex for efficient use later
      try self.regex = RegexWithGroups(pattern: self.pattern)
      let groupNames = self.regex!.groupNames()
      
      if groupNames.count != 2 || groupNames[0] != "key" || groupNames[1] != "value" {
        log("regular expression does not have groups 'key' and 'value': \(self.pattern)")
        return false
      }
      
      return true
    } catch {
      log("invalid regular expression: \(self.pattern)")
      return false
    }
  }
  
  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let pattern=line.rest(), line.done(){
      self.pattern = pattern
      do {
        try self.regex = RegexWithGroups(pattern: self.pattern)
        let groupNames = self.regex!.groupNames()
        
        if groupNames.count != 2 || groupNames[0] != "key" || groupNames[1] != "value" {
          log("regular expression does not have groups 'key' and 'value': \(self.pattern)")
          return false
        }
      } catch {
        log("invalid regular expression: \(self.pattern)")
        return false
      }
      
      return true
    } else {
      log("expected 1 argument, pattern")
      return false
    }
  }
  
  
  func changesData() -> Bool {
    true
  }
  
  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    
    log("Applying key/value expression: \(self.pattern)")
    
    if let regex {
      logLines.parseFields(regex: regex)
      log("... \(logLines.count) line(s) processed")
      return true
    } else {
      log("... regex not set")
      return false
    }
    
  }
  
  func undoText() -> String {
    return "\(ParseFieldsCommand.description[0].op)"
  }
  
  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .analysis,
        op: "kv",
        args: "regex",
        description:
          "parse lines for key/value pairs.  Regex must specify named groups \"key\" and \"value\"."
      )
    ]
  }
  
}
