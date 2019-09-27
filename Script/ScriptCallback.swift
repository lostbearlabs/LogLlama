
import Foundation

/**
 As the script engine executes, it invokes this callback to report its progress.
 */
protocol ScriptCallback {
    func scriptStarted()
    func scriptUpdate(text: String)
    func scriptDone(logLines: [LogLine])
}
