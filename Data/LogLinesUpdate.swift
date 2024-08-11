import Foundation

/**
 Sent from the ScriptViewController at the end of script execution and used by the ResultsViewController to update its display.
 */
class LogLinesUpdate {
    var lines : LogLineArray
    
    init(lines : LogLineArray) {
        // clone the lines so that the original owner (the ScriptView) can continue to update its state
        // without affecting the display or undo data
        self.lines = lines.clone()
    }
}
