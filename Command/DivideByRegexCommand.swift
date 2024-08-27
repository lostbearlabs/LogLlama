import Foundation

/// This command adds section headers to the log whenever the specified regex is matched
class DivideByRegexCommand: ScriptCommand {
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
        try regex = RegexWithGroups(pattern: pattern)
        return true
      } catch {
        log("invalid regular expression: \(pattern)")
        return false
      }
    } else {
      log("expected 1 argument, pattern")
      return false
    }
  }


  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    if let regex {
      let numFound = logLines.divideByRegex(regex: regex, color: runState.color)
      log("Found \(numFound) section boundaries where lines match regex \(self.pattern)")
      return true
    } else {
      log("regex not defined")
      return false
    }
  }

  func undoText() -> String {
    return "\(DivideByRegexCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .sections,
        op: "/r",
        args: "regex",
        description: "mark lines that match regex as section headers"
      )
    ]
  }

}
