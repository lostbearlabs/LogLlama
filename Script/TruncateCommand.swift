import Foundation

class TruncateCommand : ScriptCommand {

    var maxLength : Int
    var callback : ScriptCallback

    init(callback: ScriptCallback, maxLength: Int) {
          self.callback = callback
        self.maxLength = maxLength
    }

    func validate() -> Bool {
        return true
    }

    func changesData() -> Bool {
        true
    }

    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "Truncating lines to \(self.maxLength) characters")

        var n = 0
        for line in logLines {
            if line.truncate(maxLength: self.maxLength) {
                n += 1
            }
        }

        self.callback.scriptUpdate(text: "... truncated \(n) of \(logLines.count) lines")
        return true
    }


}
