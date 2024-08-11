/**
 This command adds section headers into the log whenever the specified field changes value.  This probably only makes sense to use if the log is sorted by the field.
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
    
    
    func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
        var prev : String? = nil
        
        var numLines = 0
        var numSections = 0
        for line in logLines {
            numLines += 1
            let val = line.namedFieldValues[self.field]
            if val != prev {
                numSections += 1
                line.setBeginSection(color: runState.color)
            }
            prev = val
        }
        
        self.callback.scriptUpdate(text: "Found \(numSections) section boundaries where value of \(self.field) changes")
        return true
    }
    
    func description() -> String {
        return "/f"
    }
    
}
