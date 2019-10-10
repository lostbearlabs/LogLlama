import Foundation

/**
 This command removes all hidden lines from the list of log lines.  This will speed up subsequent processing, but it means those lines are no longer available
 to be restored by a "+" filter or analyzed by other commands.
 */
class ChopCommand : ScriptCommand {
    var callback : ScriptCallback

      init(callback: ScriptCallback) {
          self.callback = callback
      }

    func validate() -> Bool {
        true
    }
    
    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "Removing hidden lines")
        let initialCount = logLines.count
        logLines.removeAll( where: {!$0.visible})
        let removedCount = initialCount - logLines.count
        self.callback.scriptUpdate(text: "... removed \(removedCount) hidden lines")
        return true
    }
    
    
}
