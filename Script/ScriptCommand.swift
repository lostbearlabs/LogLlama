import Foundation

protocol ScriptCommand {
    func validate() -> Bool;
    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool;
}
