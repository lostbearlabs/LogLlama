import Foundation

/**
 This engine executes script text, using a ScriptParser to parse the text and then invoking the resulting list of commands in order.
 */
class ScriptEngine {
    var callback : ScriptCallback
    var initialLines : [LogLine] = []
    var runState = RunState()
    
    init(callback : ScriptCallback) {
        self.callback = callback
    }
    
    func setInitialLines( lines : [LogLine] ) {
        self.initialLines = lines;
    }

    func setRunState( runState : RunState ) {
        self.runState = runState
    }
    
    func run(script : String) {
        self.callback.scriptStarted()
        
        let parser = ScriptParser(callback: self.callback)
        let (rc, commands) = parser.parse(script: script)
        if( !rc ) {
            self.callback.scriptUpdate(text: "PARSING FAILED")
            self.callback.scriptDone(logLines: [])
            return
        }
        
        if commands.count==0 {
            self.callback.scriptUpdate(text: "NO COMMANDS IN SCRIPT")
            self.callback.scriptDone(logLines: [])
            return
        }
        
        for cmd in commands {
            if( !cmd.validate()) {
                self.callback.scriptDone(logLines: [])
                return
            }
        }
        
        var logLines = self.initialLines;
        var anyChanges = false
        for cmd in commands {

            // If this is a command that changes the log lines on screen, then clear our
            // SQL data;  it will need to be rebuilt for the next query
            if cmd.changesData() {
                anyChanges = true
                self.runState.fieldDataSql = nil
            }

            let start = DispatchTime.now()
            
            if( !cmd.run(logLines: &logLines, runState: &self.runState)) {
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

        if( anyChanges ) {
            self.callback.scriptUpdate(text: "Found \(n) lines to display")
        }
        self.callback.scriptDone(logLines: logLines)
    }
    
}
