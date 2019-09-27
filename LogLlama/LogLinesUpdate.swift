import Foundation

/**
 Sent from the ScriptViewController at the end of script execution and used by the ResultsViewController to update its display.
 */
class LogLinesUpdate {
    var lines : [LogLine]
    
    init(lines : [LogLine]) {
        self.lines = lines
    }
}
