import Foundation

/**
 A log line, read from a file (or generated internally as demo data) and then updated by ScriptCommands.
 */
class LogLine {
    var text : String = ""
    var visible  = true
    var attributed : NSMutableAttributedString = NSMutableAttributedString(string: "")
    static var rxNumber:NSRegularExpression? = nil
    static var rxValue:NSRegularExpression? = nil
    var matched = false
    var namedFieldValues:[String: String] = [:]

    init(text : String) {
        
        if( LogLine.rxNumber == nil || LogLine.rxValue == nil ) {
            do {
            LogLine.rxNumber = try NSRegularExpression(pattern: "\\d", options: NSRegularExpression.Options.caseInsensitive)
            LogLine.rxValue = try NSRegularExpression(pattern: "=[^,]+", options: NSRegularExpression.Options.caseInsensitive)
            } catch {
                NSLog("ERROR INITIALIZING REGEX")
            }
        }
        
        self.initFromText(text: text)
    }

    func truncate(maxLength : Int) -> Bool {
        if( self.text.count <= maxLength ) {
            return false
        }

        self.initFromText(text: String(self.text.prefix(maxLength)))
        return true
    }

    private func initFromText(text: String) {
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

    func clone() -> LogLine {
        let copy = LogLine(text: self.text)
        copy.visible = self.visible
        copy.matched = self.matched
        copy.attributed = NSMutableAttributedString(attributedString: self.attributed.copy() as! NSAttributedString)
        return copy
    }
    
}
