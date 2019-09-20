
import Foundation

protocol ScriptCallback {
    func scriptStarted()
    func scriptUpdate(text: String)
    func scriptDone(logLines: [LogLine])
}
