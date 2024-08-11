import Foundation

/**
 Applies an = filter with today's date
 */
class TodayCommand : FilterLineCommand {
    init(callback: ScriptCallback) {
        super.init(callback: callback, pattern: "date-format-replaced-at-runtime-with-current-date", filterType: FilterType.Required)
    }
    
    override func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
        
        // We have to set this up now, not at validation time, so it gets the most recent dateFormat value
        if( !self.setupToday(runState: runState)) {
            return false
        }
        
        return super.run(logLines: &logLines, runState: &runState)
    }
    
    func setupToday(runState : RunState) -> Bool {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = runState.dateFormat
        self.pattern = formatter.string(from: now)
        
        do {
            try self.regex = RegexWithGroups(pattern: self.pattern)
            return true
        } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
        }
    }
    
    override func description() -> String {
        return "today"
    }
    
    
}
