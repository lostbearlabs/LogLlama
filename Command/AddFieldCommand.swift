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
    var map: [String: String] = [:]

    for line in logLines {
      if line.namedFieldValues.keys.contains(self.fieldToAdd)
        && line.namedFieldValues.keys.contains(self.fieldToMatch)
      {
        let key = line.namedFieldValues[self.fieldToMatch]!
        let val = line.namedFieldValues[self.fieldToAdd]!
        map.updateValue(val, forKey: key)
      }
    }
    self.callback.scriptUpdate(
      text: "Found \(map.count) mappings from \(self.fieldToMatch) to \(self.fieldToAdd)")

    var numUpdated = 0
    var numSkipped = 0
    var numTotal = 0
    for line in logLines {
      if !line.namedFieldValues.keys.contains(self.fieldToAdd)
        && line.namedFieldValues.keys.contains(self.fieldToMatch)
      {
        numTotal += 1
        let key = self.fieldToAdd
        let match = line.namedFieldValues[self.fieldToMatch]!
        if map.keys.contains(match) {
          let val = map[match]!
          line.namedFieldValues.updateValue(val, forKey: key)
          numUpdated += 1
        } else {
          numSkipped += 1
        }
      }
    }

    if numTotal == 0 {
      self.callback.scriptUpdate(
        text: "Found 0 lines that have \(self.fieldToMatch) but not \(self.fieldToAdd)")
    } else {
      self.callback.scriptUpdate(
        text:
          "Updated \(numUpdated) lines that have \(self.fieldToMatch) but not \(self.fieldToAdd), skipped \(numSkipped)"
      )
    }
    return true
  }

  func description() -> String {
    return "@"
  }

}
