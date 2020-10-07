/**
 This command adds story headers to the log whenever the specified regex is matched
 */
class DivideByRegexCommand : ScriptCommand {
    var callback : ScriptCallback
    var regex : String

    init(callback: ScriptCallback, regex: String) {
        self.callback = callback
        self.regex = regex
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
