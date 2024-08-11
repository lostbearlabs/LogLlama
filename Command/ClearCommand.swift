import Foundation

/**
 This command removes ALL lines from the list of log lines.  It is useful when running interactively to reset
 your state.
 */
class ClearCommand : ScriptCommand {
    var callback : ScriptCallback
    
    init(callback: ScriptCallback) {
        self.callback = callback
    }
    
    func validate() -> Bool {
        true
    }
    
    func changesData() -> Bool {
        true
    }
    
    
    func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
        logLines.clear()
        self.callback.scriptUpdate(text: "Cleared all lines")
        return true
    }
    
    func description() -> String {
        return "clear"
    }
    
}
