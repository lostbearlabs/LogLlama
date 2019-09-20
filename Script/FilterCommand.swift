import Foundation
import AppKit

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
    
    func run(logLines: inout [LogLine]) -> Bool {

        self.callback.scriptUpdate(text: "applying regular expression: \(self.pattern)")
        
        var n = 0
        for line in logLines {
            let results = regex!.matches(in: line.text,
                                        range: NSRange(line.text.startIndex..., in: line.text))

            var match = false
            if results.count > 0 {
                match = true
                n += 1
                
                let _ = results.map {
                    let color = NSColor.green
                    line.attributed.addAttribute(.backgroundColor, value: color, range: $0.range)
                }
                
            }
            
            switch( self.filterType ) {
                
            case .Required:
                line.visible = match
            case .Add:
                line.visible = line.visible || match
            case .Remove:
                line.visible = line.visible && !match
            case .Highlight:
                ()
            }
            
        }

        self.callback.scriptUpdate(text: "... \(n) line(s) matched")
        
        return true
    }
    
    
}
