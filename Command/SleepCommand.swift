import Foundation

class SleepCommand: ScriptCommand {

  var seconds: Int = 0
  var callback: ScriptCallback?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }
  
  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let seconds=line.popInt(), line.done(){
      self.seconds = seconds
      return true
    } else {
      log("expected 1 int argument, num seconds")
      return false
    }
  }


  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    log("sleeping for \(self.seconds) seconds")
    Thread.sleep(forTimeInterval: Double(seconds))
    return true
  }

  func undoText() -> String {
    return SleepCommand.description[0].op
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .misc,
        op: "sleep",
        args: "N",
        description: "sleep for N seconds (for testing UI updates during script processing)"
      )
    ]
  }

}
