import Foundation

class LimitCommand: ScriptCommand {

  var limit: Int = 0
  var callback: ScriptCallback?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {
    return true
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let limit = line.popInt(), line.done() {
      self.limit = limit
      return true
    } else {
      log("expected 1 integer argument, line count limit")
      return false
    }
  }

  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    log("Limiting files to \(self.limit) lines")
    runState.limit = self.limit
    return true
  }

  func undoText() -> String {
    return "\(LimitCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .adding,
        op: "limit",
        args: "N",
        description: "truncate files with > N lines"
      )
    ]
  }

}
