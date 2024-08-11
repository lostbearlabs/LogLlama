import Foundation

/**
 Describes any command produced by the ScriptParser and executed by the ScriptEngine.
 */
protocol ScriptCommand {
    func validate() -> Bool;
    func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool;
    func changesData() -> Bool;
    func description() -> String;
}
