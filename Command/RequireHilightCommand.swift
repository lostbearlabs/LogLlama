import Foundation

/// This command hides all non-hilighted lines.
class RequireHilightCommand: ScriptCommand {
  var callback: ScriptCallback

  init(callback: ScriptCallback) {
    self.callback = callback
  }

  func validate() -> Bool {
    true
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    self.callback.scriptUpdate(text: "Hiding non-hilighed lines")
    let n = logLines.hideNotHilighted()
    self.callback.scriptUpdate(text: "... hid \(n) non-hilighted lines")
    return true
  }

  func description() -> String {
    return "=="
  }

}
