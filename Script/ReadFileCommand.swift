import Foundation

/**
 Inputs log lines from a log file.
 */
class ReadFileCommand : ScriptCommand {
    var callback : ScriptCallback
    var file : String
    
    init(callback: ScriptCallback, file: String) {
        self.callback = callback
        self.file = file
    }
    
    func validate() -> Bool {
        if( !FileManager.default.fileExists(atPath: self.file)) {
            self.callback.scriptUpdate(text: "file does not exist: \(self.file)")
            return false
        }
        return true
    }
    
    func run(logLines : inout [LogLine], runState _ : inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "reading file \(self.file)")

        do {
            let data = try String(contentsOfFile: self.file, encoding: .utf8)
            let ar = data.components(separatedBy: .newlines)
            for line in ar {
                logLines.append( LogLine(text: line))
            }
            self.callback.scriptUpdate(text: "... read \(ar.count) lines")
            return true
        } catch {
            self.callback.scriptUpdate(text: "... error reading file: \(error)")
            return false
        }
        
    }
    
    
}
