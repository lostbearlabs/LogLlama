/// This command re-sorts the log lines in order of the field(s) specified.
///
/// If all fields match (or none are specified) then it defaults to sorting by the original line numbers from the LogLineArray (which correspond to the
/// file number for individual files, and increment from there for multiple files).
class SortByFieldsCommand: ScriptCommand {
  var callback: ScriptCallback?
  var fields: [String] = []

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
    if let fieldsString=line.rest(), line.done(){
      self.fields = fieldsString.split(separator: " ").map({ String($0) })
      return true
    } else {
      log("expected 1 argument, comma-separated field list")
      return false
    }
  }


  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    logLines.sortByFields(fieldNames: fields)
    log("Sorted \(logLines.count) log lines")
    return true
  }

  func undoText() -> String {
    return SortByFieldsCommand.description[0].op
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .misc,
        op: "sort",
        args: "field1, field2, ...",
        description:
          "sort lines according to field list, with line number comparison as the last condition"
      )
    ]
  }

}
