import Foundation

/**
 Sets the date format to be used in subsequent "today" and "requireToday" commands.
 */
class DateFormatCommand : ScriptCommand {
    var text : String
    var callback : ScriptCallback
    
    init(callback: ScriptCallback, text: String) {
        self.callback = callback
        self.text = text
    }
    
    func validate() -> Bool {
        return true
    }
    
    func changesData() -> Bool {
        false
    }
    
    func run(logLines: inout LogLineArray, runState : inout RunState) -> Bool {
        runState.dateFormat = self.text
        self.callback.scriptUpdate(text: "Date format is now: \(runState.dateFormat)")
        return true
    }
    
    func description() -> String {
        return "dateFormat"
    }
    
}
