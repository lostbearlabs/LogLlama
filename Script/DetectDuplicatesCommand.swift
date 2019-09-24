import Foundation

class DetectDuplicatesCommand : ScriptCommand {
    
    var callback : ScriptCallback
    var threshold : Int
    
    init(callback: ScriptCallback, threshold: Int) {
        self.callback = callback
        self.threshold = threshold
    }
    
    func validate() -> Bool {
        return true
    }
    
    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        var counts : [String: Int] = [:]

        self.callback.scriptUpdate(text: "Looking for lines that occur more that \(self.threshold) times")
        
        for line in logLines {
            let x = line.getAnonymousString()
            if counts.contains(where: {$0.key == x}) {
                counts[x] = counts[x]! + 1
            } else {
                counts[x] = 1
            }
        }
        
        var repeated : [String] = []
        for( text, count ) in counts {
            if count > self.threshold {
                self.callback.scriptUpdate(text: "... found \(count) lines like: \(text)")
                let newLine = LogLine(text: "[\(count) LINES LIKE THIS] \(text)")
                logLines.insert(newLine, at:0)
                repeated.append(text)
            }
        }
        
        // TODO: also filter them??
        
        return true
    }
    
    
}
