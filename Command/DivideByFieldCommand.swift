/// This command adds section headers into the log whenever the specified field changes value.  This probably only makes sense to use if the log is sorted by the field.
class DivideByFieldCommand: ScriptCommand {
  var callback: ScriptCallback?
  var field: String = ""

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
    if let field = line.pop(), line.done() {
      self.field = field
      return true
    } else {
      log("expected 1 argument, field")
      return false
    }
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    let numSections = logLines.divideByField(field: self.field, color: runState.color)

    log("Found \(numSections) section boundaries where value of \(self.field) changes")

    return true
  }

  func description() -> String {
    return "/f"
  }

  func undoText() -> String {
    return "\(DivideByFieldCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .sections,
        op: "/f",
        args: "field",
        description: "mark lines where the value of field changes as section headers"
      )
    ]
  }

}
