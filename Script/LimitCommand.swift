import Foundation

class LimitCommand : ScriptCommand {

    var limit : Int
    var callback : ScriptCallback

    init(callback: ScriptCallback, limit: Int) {
          self.callback = callback
        self.limit = limit
    }

    func validate() -> Bool {
        return true
    }

    func changesData() -> Bool {
        false
    }

    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "Limiting files to \(self.limit) lines")
        runState.limit = self.limit
        return true
    }

    func description() -> String {
        return "limit"
    }


}
