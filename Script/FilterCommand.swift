import Foundation
import AppKit

/**
 Applies a regular expression to LogLines, coloring and filtering them depending whether they match.
 
 This command implements all 4 of our filtering operations.
 */
class FilterCommand : ScriptCommand {

    enum FilterType {
        case Required
        case Add
        case Remove
        case Highlight
    }
    
    var callback : ScriptCallback
    var filterType : FilterType
    var pattern : String
    var regex : NSRegularExpression?
    
    init(callback: ScriptCallback, pattern: String, filterType : FilterType) {
        self.callback = callback
        self.pattern = pattern
        self.filterType = filterType
    }
    
    
    
    func validate() -> Bool {
        do {
            try self.regex = NSRegularExpression(pattern: self.pattern, options: [])
            return true
        } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
        }
    }
    
    func run(logLines: inout [LogLine], runState : inout RunState) -> Bool {

        self.callback.scriptUpdate(text: "applying regular expression: \(self.pattern)")
        
        var n = 0
        DispatchQueue.concurrentPerform(iterations: logLines.count) { (index) in
            
            let line = logLines[index]
            let results = regex!.matches(in: line.text,
                                        range: NSRange(line.text.startIndex..., in: line.text))

            var match = false
            if results.count > 0 {
                match = true
                n += 1
                
                let _ = results.map {
                    line.attributed.addAttribute(.backgroundColor, value: runState.color, range: $0.range)
                }
                
            }
            
            switch( self.filterType ) {
                
            case .Required:
                line.visible = match
                line.matched = line.matched || match
            case .Add:
                line.visible = line.visible || match
                line.matched = line.matched || match
            case .Remove:
                line.visible = line.visible && !match
                line.matched = line.matched && !match
            case .Highlight:
                line.matched = line.matched || match
            }

        }

        self.callback.scriptUpdate(text: "... \(n) line(s) matched")
        
        return true
    }
    
    
}
