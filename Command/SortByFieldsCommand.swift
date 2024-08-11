/// This command re-sorts the log lines in order of the field(s) specified.
///
/// If all fields match (or none are specified) then it defaults to sorting by the original line numbers.
/// (TODO: this breaks down if there are lines from multiple files; maybe also include date or file name?)
class SortByFieldsCommand: ScriptCommand {
  var callback: ScriptCallback
  var fields: [String]

  init(callback: ScriptCallback, fieldsString: String) {
    self.callback = callback
    self.fields = fieldsString.split(separator: " ").map({ String($0) })
  }

  func validate() -> Bool {
    true
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    logLines.sortByFields(fieldNames: fields)
    self.callback.scriptUpdate(text: "Sorted \(logLines.count) log lines")
    return true
  }

  func description() -> String {
    return "sort"
  }

}
