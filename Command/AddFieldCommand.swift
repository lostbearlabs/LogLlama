/// This command enhances the fields of a log line with an additional field, if a value for the additional field can be found on a line with the same value in the match field.
class AddFieldCommand: ScriptCommand {
  var callback: ScriptCallback? = nil
  var fieldToAdd: String = ""
  var fieldToMatch: String = ""

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let arg1 = line.pop(), let arg2 = line.pop(), line.done() {
      self.fieldToAdd = arg1
      self.fieldToMatch = arg2
      return true
    } else {
      log("expected 2 arguments, field1 and field2")
      return false
    }
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    let n = logLines.addField(fieldToAdd: self.fieldToAdd, fieldToMatch: self.fieldToMatch)

    log(
      "Propagated known values from \(self.fieldToMatch) to missing \(self.fieldToAdd) on \(n) lines"
    )

    return true
  }

  func undoText() -> String {
    return "\(AddFieldCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .adjusting,
        op: "@",
        args: "field1 field2",
        description:
          "populate lines that have field2 but not field1 with the value from another line that has field1 and the same value of field2"
      )
    ]
  }

}
