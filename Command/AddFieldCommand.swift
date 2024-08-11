/// This command enhances the fields of a log line with an additional field, if a value for the additional field can be found on a line with the same value in the match field.
class AddFieldCommand: ScriptCommand {
  var callback: ScriptCallback
  var fieldToAdd: String
  var fieldToMatch: String

  init(callback: ScriptCallback, fieldToAdd: String, fieldToMatch: String) {
    self.callback = callback
    self.fieldToAdd = fieldToAdd
    self.fieldToMatch = fieldToMatch
  }

  func validate() -> Bool {
    true
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    let n = logLines.addField(fieldToAdd: self.fieldToAdd, fieldToMatch: self.fieldToMatch)

    self.callback.scriptUpdate(
      text:
        "Propagated known values from \(self.fieldToMatch) to missing \(self.fieldToAdd) on \(n) lines"
    )

    return true
  }

  func description() -> String {
    return "@"
  }

}
