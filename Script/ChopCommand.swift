import Foundation

class ChopCommand : ScriptCommand {
    var callback : ScriptCallback

      init(callback: ScriptCallback) {
          self.callback = callback
      }

    func validate() -> Bool {
        return true
    }
    
    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "removing hidden lines")
        let initialCount = logLines.count
        logLines.removeAll( where: {return !$0.visible})
        let removedCount = initialCount - logLines.count
        self.callback.scriptUpdate(text: "... removed \(removedCount) hidden lines")
        return true
    }
    
    
}
