import Foundation

/// This command hides all non-hilighted lines.
class RequireHilightCommand: ScriptCommand {
  var callback: ScriptCallback?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {
    true
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if line.done() {
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
    log("Hiding non-hilighed lines")
    let n = logLines.hideNotHilighted()
    log("... hid \(n) non-hilighted lines")
    return true
  }

  func undoText() -> String {
    return "\(RequireHilightCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .filter,
        op: "==",
        args: "",
        description: "hide all lines not already hilighted"
      )
    ]
  }

}
