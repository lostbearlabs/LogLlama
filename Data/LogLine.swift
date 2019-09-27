import Foundation

/**
 A log line, read from a file (or generated internally as demo data) and then updated by ScriptCommands.
 */
class LogLine {
    var text : String
    var visible  = true
    var attributed : NSMutableAttributedString
    static var rxNumber:NSRegularExpression? = nil
    static var rxValue:NSRegularExpression? = nil

    init(text : String) {
        
        if( LogLine.rxNumber == nil || LogLine.rxValue == nil ) {
            do {
            LogLine.rxNumber = try NSRegularExpression(pattern: "\\d", options: NSRegularExpression.Options.caseInsensitive)
            LogLine.rxValue = try NSRegularExpression(pattern: "=[^,]+", options: NSRegularExpression.Options.caseInsensitive)
            } catch {
                NSLog("ERROR INITIALIZING REGEX")
            }
        }
        
        self.text = text
        self.attributed = NSMutableAttributedString(string: self.text)
    }
    
    func getAttributedString() -> NSMutableAttributedString {
        self.attributed
    }
    
    func getAnonymousString() -> String {
        var st = self.text;

        st = LogLine.rxValue!.stringByReplacingMatches(
                in: st,
                options: NSRegularExpression.MatchingOptions.withTransparentBounds,
                range: NSMakeRange(0, st.count),
                withTemplate: "=VAL")
        
        st = LogLine.rxNumber!.stringByReplacingMatches(
                in: st,
                options: NSRegularExpression.MatchingOptions.withTransparentBounds,
                range: NSMakeRange(0, st.count),
                withTemplate: "N")

        return st
    }
    
    
}
