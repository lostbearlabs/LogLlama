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
            self.callback.scriptDone(logLines: [])
            return
        }
        
        if cmds.count==0 {
            self.callback.scriptUpdate(text: "NO COMMANDS IN SCRIPT")
            self.callback.scriptDone(logLines: [])
            return
        }
        
        var runState = RunState()
        
        for cmd in cmds {
            if( !cmd.validate()) {
                self.callback.scriptDone(logLines: [])
                return
            }
        }
        
        var logLines : [LogLine] = []
        for cmd in cmds {
            let start = DispatchTime.now()
            
            if( !cmd.run(logLines: &logLines, runState: &runState)) {
                self.callback.scriptDone(logLines: logLines)
                return
            }
            
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = round( 1_000 * Double(nanoTime) / 1_000_000_000) / 1000
            
            self.callback.scriptUpdate(text: "... (\(timeInterval) seconds)")
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
