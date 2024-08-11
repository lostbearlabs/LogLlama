import Foundation

class UndoState {
  var lines: LogLineArray
  var op: String?
  var runState: RunState

  init(op: String?, lines: LogLineArray, runState: RunState) {
    self.op = op

    // clone each line so that the original owner (the ScriptView) can continue to update its state
    // without affecting the display or undo data
    self.lines = lines.clone()

    self.runState = runState
  }

  var count: Int {
    return lines.count
  }
}
