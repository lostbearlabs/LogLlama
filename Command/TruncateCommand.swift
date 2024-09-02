import Foundation

class TruncateCommand: ScriptCommand {

  var maxLength: Int = 0
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
    if let maxLength = line.popInt(), line.done() {
      self.maxLength = maxLength
      return true
    } else {
      log("expected 1 integer argument, max line length")
      return false
    }
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    log("Truncating lines to \(self.maxLength) characters")

    var n = 0
    for line in logLines {
      if line.truncate(maxLength: self.maxLength) {
        n += 1
      }
    }

    log("... truncated \(n) of \(logLines.count) lines")
    return true
  }

  func undoText() -> String {
    return "\(TruncateCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .adjusting,
        op: "truncate",
        args: "N",
        description: "truncate lines with > N characters"
      )
    ]
  }

}
