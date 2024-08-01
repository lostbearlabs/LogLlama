import Foundation
@testable import LogLlama


class ScriptCallbackStub : ScriptCallback {
    func scriptStarted() {
    }
    
    func scriptUpdate(text: String) {
    }
    
    func scriptDone(logLines: [LogLine], op: String?) {
    }
}
