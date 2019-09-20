import Foundation

class LogLine {
    var text : String
    var visible  = true
    var attributed : NSMutableAttributedString
    
    init(text : String) {
        self.text = text
        self.attributed = NSMutableAttributedString(string: self.text)
    }
    
    func getAttributedString() -> NSMutableAttributedString {
        return self.attributed
    }
    
}
