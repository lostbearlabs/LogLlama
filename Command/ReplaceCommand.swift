import Foundation

class ReplaceCommand: ScriptCommand {

  var callback: ScriptCallback?
  var oldText: String = ""
  var newText: String = ""

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let oldText = line.pop(), let newText = line.pop(), line.done() {
      self.oldText = oldText
      self.newText = newText
      return true
    } else {
      log("expected 2 arguments, oldText and newText")
      return false
    }
  }

  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    runState.replace.updateValue(self.newText, forKey: self.oldText)
    log("Set filter to replace \(self.oldText) with \(self.newText) when reading lines")
    return true
  }

  func undoText() -> String {
    return ReplaceCommand.description[0].op
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .adding,
        op: "replace",
        args: "A B",
        description: "when importing lines, replace any occurence of A with B"
      )
    ]
  }

}
