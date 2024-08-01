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
    }

    func validate() -> Bool {
        do {
            if( self.loadFilterType == .Required || self.loadFilterType == .Excluded) {
                try self.regex = NSRegularExpression(pattern: self.pattern, options: [])
            }
            return true
        } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
        }
    }

    func changesData() -> Bool {
        false
    }


    func run(logLines: inout [LogLine], runState : inout RunState) -> Bool {
        switch( self.loadFilterType ) {

        case .Required:
            runState.filterRequired.append(self.regex!)
            self.callback.scriptUpdate(text: "Added filter: Lines loaded must match: \(self.pattern)")
            return true
        case .RequireToday:
            // We have to set this up now, not at validation time, so it gets the most recent dateFormat value
            return self.setupToday(runState: runState)
        case .Excluded:
            self.callback.scriptUpdate(text: "Added filter: Lines loaded must not match: \(self.pattern)")
            runState.filterExcluded.append(self.regex!)
            return true
        case .Clear:
            self.callback.scriptUpdate(text: "Cleared filters on lines loaded")
            runState.filterRequired.removeAll()
            runState.filterExcluded.removeAll()
            return true
        }

    }

    func setupToday(runState : RunState) -> Bool {
        let now = Date()
          let formatter = DateFormatter()
          formatter.dateFormat = runState.dateFormat
          let pattern = formatter.string(from: now)
          self.pattern = pattern

          do {
            try self.regex = NSRegularExpression(pattern: self.pattern, options: [])
            runState.filterRequired.append(self.regex!)
            self.callback.scriptUpdate(text: "Added filter: Lines loaded must match: \(self.pattern)")
            return true
          } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
          }
    }
    
    func description() -> String {
        return "\(self.loadFilterType)"
    }


}

