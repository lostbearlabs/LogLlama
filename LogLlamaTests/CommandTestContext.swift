import Foundation
@testable import LogLlama

class CommandTestContext : ScriptCallback {
    var lines : [LogLine] = []
    var runState : RunState = RunState()

    func addLines(numLines: Int) {
        for i in 1...numLines {
            self.lines.append(LogLine(text: "Line \(i)", lineNumber: i))
        }
    }

    func scriptStarted() {
    }

    func scriptUpdate(text: String) {
    }

    func scriptDone(logLines: [LogLine], op: String?) {
    }

}
