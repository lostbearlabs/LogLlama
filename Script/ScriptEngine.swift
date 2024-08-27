import Foundation

/// This engine executes script text, using a ScriptParser to parse the text and then invoking the resulting list of commands in order.
class ScriptEngine {
  var callback: ScriptCallback
  var initialLines: LogLineArray = LogLineArray()
  var runState = RunState()

  init(callback: ScriptCallback) {
    self.callback = callback
  }

  func log(_ st: String) {
    self.callback.scriptUpdate(text: st)
  }

  func setInitialLines(lines: LogLineArray) {
    self.initialLines = lines
  }

  func setRunState(runState: RunState) {
    self.runState = runState
  }

  func run(script: String) {
    self.callback.scriptStarted()

    let parser = ScriptParser(callback: self.callback)
    let (rc, commands) = parser.parse(script: script)
    if !rc {
      log("PARSING FAILED")
      self.callback.scriptDone(logLines: LogLineArray(), op: nil)
      return
    }

    if commands.count == 0 {
      log("NO COMMANDS IN SCRIPT")
      self.callback.scriptDone(logLines: LogLineArray(), op: nil)
      return
    }

    var logLines = self.initialLines
    var anyChanges = false
    let firstCmd = commands[0].undoText()
    var lastCmd = ""
    for cmd in commands {
      lastCmd = cmd.undoText()

      // If this is a command that changes the log lines on screen, then clear our
      // SQL data;  it will need to be rebuilt for the next query
      if cmd.changesData() {
        anyChanges = true
        self.runState.fieldDataSql = nil
      }

      let start = DispatchTime.now()

      if !cmd.run(logLines: &logLines, runState: &self.runState) {
        self.callback.scriptDone(logLines: logLines, op: nil)
        return
      }

      let end = DispatchTime.now()
      let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
      let timeInterval = round(1_000 * Double(nanoTime) / 1_000_000_000) / 1000

      log("... (\(timeInterval) seconds)")
    }

    var n = 0
    for line in logLines {
      if line.visible {
        n += 1
      }
    }

    if anyChanges {
      log("Found \(withCommas(n)) lines to display")
    }

    let op = commands.count == 1 ? firstCmd : "\(firstCmd) .. \(lastCmd)"
    self.callback.scriptDone(logLines: logLines, op: op)
  }

}
