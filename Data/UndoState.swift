import Foundation

class UndoState {
    var lines : [LogLine]
    var op : String?
    var runState : RunState
    
    init(op: String?, lines: [LogLine], runState: RunState) {
        self.op = op
        self.lines = []
        for line in lines {
            // clone each line so that the original owner (the ScriptView) can continue to update its state
            // without affecting the display or undo data
            self.lines.append(line.clone())
        }
        self.runState = runState
    }
}
