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
    var groupNames : [String]?
    
    init(callback: ScriptCallback, pattern: String, filterType : FilterType) {
        self.callback = callback
        self.pattern = pattern
        self.filterType = filterType
    }

    func validate() -> Bool {
        do {
            // parse the regex for efficient use later
            try self.regex = NSRegularExpression(pattern: self.pattern, options: [])

            // analyze the regex for named groups -- there's nothing built into NSRegularExpression to get group names
            let nameRegex = try NSRegularExpression(pattern: "\\(\\?\\<(\\w+)\\>", options: [])
            let nameMatches : [NSTextCheckingResult] = nameRegex.matches(in: self.pattern, options: [], range: NSMakeRange(0, self.pattern.count))
            self.groupNames = nameMatches.map { (textMatch : NSTextCheckingResult) -> String in
                let range = Range(textMatch.range(at: 1), in: self.pattern)!
                return String(self.pattern[range])
             }

            return true
        } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
        }
    }

    func changesData() -> Bool {
        true
    }

    
    func run(logLines: inout [LogLine], runState : inout RunState) -> Bool {

        self.callback.scriptUpdate(text: "Applying regular expression: \(self.pattern)")
        self.callback.scriptUpdate(text: "... field names: \(self.groupNames!.sorted())")

        
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
                    let match = $0

                    // add hilite color to display text
                    line.attributed.addAttribute(.backgroundColor, value: runState.color, range: match.range)

                    // save named fields for use by later queries
                    let _ = self.groupNames!.map { (groupName : String) -> String in
                        let groupRange:NSRange = match.range(withName: groupName)
                        if groupRange.location != NSNotFound {
                            let range = Range(groupRange, in: line.text)!
                            let value = String(line.text[range])
                            line.namedFieldValues[groupName] = value
                        }
                        return ""
                    }
                }
            }
            
            switch( self.filterType ) {
                
            case .Required:
                line.visible = line.visible && match
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
