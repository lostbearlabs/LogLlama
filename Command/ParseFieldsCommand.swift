import Foundation
import AppKit

/**
 Applies a regular expression with groups 'key' and 'value' to logLines, extracting field/value pairs for each line.
 */
class ParseFieldsCommand : ScriptCommand {
    
    var callback : ScriptCallback
    var pattern : String
    var regex : RegexWithGroups?
    
    init(callback: ScriptCallback, pattern: String) {
        self.callback = callback
        self.pattern = pattern
    }
    
    func validate() -> Bool {
        do {
            // parse the regex for efficient use later
            try self.regex = RegexWithGroups(pattern: self.pattern)
            let groupNames = self.regex!.groupNames()
            
            if( groupNames.count != 2 || groupNames[0] != "key" || groupNames[1] != "value") {
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
    
    
    func run(logLines: inout LogLineArray, runState : inout RunState) -> Bool {
        
        self.callback.scriptUpdate(text: "Applying key/value expression: \(self.pattern)")
        
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
            let captures = self.regex!.captures(text: text)
            for capture in captures {
                let key = capture["key"]
                let value = capture["value"]
                if let key, let value {
                    logLine.namedFieldValues[key] = value
                }
            }
        }
    }
    
    func description() -> String {
        return "kv"
    }
    
}
