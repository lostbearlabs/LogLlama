import Foundation

/// This command removes ALL lines from the list of log lines.  It is useful when running interactively to reset
/// your state.
class ClearCommand: ScriptCommand {
  var callback: ScriptCallback?

  required init() {
  }
  
  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if line.done(){
      return true
    } else {
      log("expected 0 arguments")
      return false
    }
  }
  
  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    logLines.clear()
    log("Cleared all lines")
    return true
  }

  func undoText() -> String {
    return "\(ClearCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .removing,
        op: "clear",
        args: "",
        description: "remove ALL lines"
      )
    ]
  }

}
