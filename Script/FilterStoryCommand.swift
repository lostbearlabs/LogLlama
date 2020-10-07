/**
 This command displays or hides stories if any line in them matches the specified regex.
 */
class FilterStoryCommand : ScriptCommand {
    var callback : ScriptCallback
    var pattern : String
    var filterType : FilterLineCommand.FilterType

    init(callback: ScriptCallback, pattern: String, filterType: FilterLineCommand.FilterType) {
        self.callback = callback
        self.pattern = pattern
        self.filterType = filterType
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
