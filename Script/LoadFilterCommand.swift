import Foundation
import AppKit

/**
 Creates or clears filters to apply when loading lines
 */
class LoadFilterCommand: ScriptCommand {

    enum LoadFilterType {
        case Required
        case Excluded
        case Clear
        case RequireToday
    }

    var callback : ScriptCallback
    var loadFilterType : LoadFilterType
    var pattern : String
    var regex : NSRegularExpression?

    init(callback: ScriptCallback, pattern: String, loadFilterType : LoadFilterType) {
        self.callback = callback
        self.pattern = pattern
        self.loadFilterType = loadFilterType

        if self.loadFilterType == .RequireToday {
            let today = TodayCommand(callback: self.callback)
            self.pattern = today.pattern
        }

    }

    func validate() -> Bool {
        do {
            if( self.loadFilterType != .Clear) {
                try self.regex = NSRegularExpression(pattern: self.pattern, options: [])
            }
            return true
        } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
        }
    }

    func run(logLines: inout [LogLine], runState : inout RunState) -> Bool {
        switch( self.loadFilterType ) {

        case .Required:
            fallthrough
        case .RequireToday:
            self.callback.scriptUpdate(text: "Added filter: Lines loaded must match: \(self.pattern)")
            runState.filterRequired.append(self.regex!)
        case .Excluded:
            self.callback.scriptUpdate(text: "Added filter: Lines loaded must not match: \(self.pattern)")
            runState.filterExcluded.append(self.regex!)
        case .Clear:
            self.callback.scriptUpdate(text: "Cleared filters on lines loaded")
            runState.filterRequired.removeAll()
            runState.filterExcluded.removeAll()
        }

        return true
    }

}

