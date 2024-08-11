import Foundation

// TODO: test parser
class ReplaceCommand : ScriptCommand {
    
    var callback : ScriptCallback
    var oldText : String
    var newText : String
    
    init(callback: ScriptCallback, oldText: String, newText: String) {
        self.callback = callback
        self.oldText = oldText
        self.newText = newText
    }
    
    func validate() -> Bool {
        return true
    }
    
    func changesData() -> Bool {
        false
    }
    
    func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
        runState.replace.updateValue(self.newText, forKey: self.oldText)
        self.callback.scriptUpdate(text: "Set filter to replace \(self.oldText) with \(self.newText) when reading lines")
        return true
    }
    
    func description() -> String {
        return "replace"
    }
    
    
}
