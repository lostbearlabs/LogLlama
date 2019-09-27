import Foundation

/**
 Describes any command produced by the ScriptParser and executed by the ScriptEngine.
 */
protocol ScriptCommand {
    func validate() -> Bool;
    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool;
}
