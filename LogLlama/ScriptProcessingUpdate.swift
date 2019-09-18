import Foundation

class ScriptProcessingUpdate {
    var clear : Bool
    var text : String
    
    init(clear : Bool) {
        self.clear = clear
        self.text = ""
    }
    
    init(text : String) {
        self.clear = false
        self.text = text
    }
    
}
