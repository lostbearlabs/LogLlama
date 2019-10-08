import Foundation

/**
 This command hides all non-hilighted lines.
 */
class RequireHilightCommand : ScriptCommand {
    var callback : ScriptCallback

      init(callback: ScriptCallback) {
          self.callback = callback
      }

    func validate() -> Bool {
        true
    }

    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "hiding non-hilighed lines")
        var n = 0
        for line in logLines {
            if line.visible && !line.matched {
                line.visible = false
                n += 1
            }
        }
        self.callback.scriptUpdate(text: "... hid \(n) non-hilighted lines")
        return true
    }


}
