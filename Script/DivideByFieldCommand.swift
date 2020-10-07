/**
 This command adds story headers into the log whenever the specified field changes value.  This probably only makes sense to use if the log is sorted by the field.
 */
class DivideByFieldCommand : ScriptCommand {
    var callback : ScriptCallback
    var field : String

    init(callback: ScriptCallback, field: String) {
        self.callback = callback
        self.field = field
    }

    func validate() -> Bool {
        true
    }

    func changesData() -> Bool {
        true
    }


    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        logLines.removeAll()
        self.callback.scriptUpdate(text: "Cleared all lines")
        return true
    }

}
