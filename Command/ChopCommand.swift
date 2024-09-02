import Foundation

/// This command removes all hidden lines from the list of log lines.  This will speed up subsequent processing, but it means those lines are no longer available
/// to be restored by a "+" filter or analyzed by other commands.
class ChopCommand: ScriptCommand {
  var callback: ScriptCallback?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
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
    log("Removing hidden lines")
    let initialCount = logLines.count
    logLines.chop()
    let removedCount = initialCount - logLines.count
    log("... removed \(removedCount) hidden lines")
    return true
  }

  func undoText() -> String {
    return "\(ChopCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .removing,
        op: "chop",
        args: "",
        description: "remove all hidden lines"
      )
    ]
  }

}
