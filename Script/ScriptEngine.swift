import Foundation

class ScriptEngine {
    var callback : ScriptCallback
    
    init(callback : ScriptCallback) {
        self.callback = callback
    }
    
    func run(script : String) {
        self.callback.scriptStarted()
        
        let parser = ScriptParser(callback: self.callback)
        let (rc, cmds) = parser.parse(script: script)
        if( !rc ) {
            self.callback.scriptUpdate(text: "PARSING FAILED")
            return
        }
        
        if cmds.count==0 {
            self.callback.scriptUpdate(text: "NO COMMANDS IN SCRIPT")
            return
        }

        var runState = RunState()
        
        for cmd in cmds {
            if( !cmd.validate()) {
                return
            }
        }

        var logLines : [LogLine] = []
        for cmd in cmds {
            if( !cmd.run(logLines: &logLines, runState: &runState)) {
                return
            }
        }
        
        var n = 0
        for line in logLines {
            if line.visible {
                n += 1
            }
        }
        
        self.callback.scriptUpdate(text: "Found \(n) lines to display")
        self.callback.scriptDone(logLines: logLines)
    }
    
}
