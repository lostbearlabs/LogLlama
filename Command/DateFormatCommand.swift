import Foundation

/// Sets the date format to be used in subsequent "today" and "requireToday" commands.
class DateFormatCommand: ScriptCommand {
  var text: String = ""
  var callback: ScriptCallback?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  init(callback: ScriptCallback, text: String) {
    self.callback = callback
    self.text = text
  }

  func validate() -> Bool {
    return true
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let text = line.pop(), line.done() {
      self.text = text
      return true
    } else {
      log("expected 1 argument, date format")
      return false
    }
  }

  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    runState.dateFormat = self.text
    log("Date format is now: \(runState.dateFormat)")
    return true
  }

  func undoText() -> String {
    return "\(DateFormatCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .filter,
        op: "dateFormat",
        args: "regex",
        description: "set the date format for subsequent \"today\" and \"requireToday\" lines"
      )
    ]
  }

}
