import Foundation

class SleepCommand: ScriptCommand {

  var seconds: Int
  var callback: ScriptCallback

  init(callback: ScriptCallback, seconds: Int) {
    self.callback = callback
    self.seconds = seconds
  }

  func validate() -> Bool {
    return true
  }

  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    self.callback.scriptUpdate(text: "sleeping for \(self.seconds) seconds")
    Thread.sleep(forTimeInterval: Double(seconds))
    return true
  }

  func description() -> String {
    return "sleep"
  }

}
