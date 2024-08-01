import Foundation
import AppKit

/**
 Applies a regular expression with groups 'key' and 'value' to logLines, extracting field/value pairs for each line.
 */
class ParseFieldsCommand : ScriptCommand {
    
    var callback : ScriptCallback
    var pattern : String
    var regex : NSRegularExpression?
    var groupNames : [String]?
    
    init(callback: ScriptCallback, pattern: String) {
        self.callback = callback
        self.pattern = pattern
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
            
            if( groupNames==nil || groupNames?.count != 2 || groupNames?[0] != "key" || groupNames?[1] != "value") {
                self.callback.scriptUpdate(text: "regular expression does not have groups 'key' and 'value': \(self.pattern)")
                return false
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
        
        DispatchQueue.concurrentPerform(iterations: logLines.count) { (index) in
            let line = logLines[index]
            findNameValueFields(logLine: line)
        }
        
        self.callback.scriptUpdate(text: "... \(logLines.count) line(s) processed")
        
        return true
    }
    
    func findNameValueFields(logLine:LogLine) {
        if( self.regex != nil ) {
            let text = logLine.text
            let matches : [NSTextCheckingResult] = self.regex!.matches(in: text, options: [], range: NSMakeRange(0, text.count))
            for match in matches {
                let nameRange = Range(match.range(at: 1), in: text)!
                let name = String(text[nameRange])
                
                let valRange = Range(match.range(at: 2), in: text)!
                let val = String(text[valRange])
                
                logLine.namedFieldValues[name] = val
            }
        }
    }
    
    func description() -> String {
        return "kv"
    }

}
