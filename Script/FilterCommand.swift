import Foundation

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
    
    init(callback: ScriptCallback, pattern: String, filterType : FilterType) {
        self.callback = callback
        self.pattern = pattern
        self.filterType = filterType
    }
    
    
    
    func validate() -> Bool {
        do {
            try _ = NSRegularExpression(pattern: self.pattern, options: [])
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
            let match = line.text.range(of: self.pattern, options: .regularExpression) != nil
            if match {
                n += 1
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
