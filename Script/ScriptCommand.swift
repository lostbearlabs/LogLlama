import Foundation

/// Describes any command produced by the ScriptParser and executed by the ScriptEngine.
protocol ScriptCommand {
  init()
  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool
  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool
  func changesData() -> Bool
  func undoText() -> String
  static var description: [ScriptCommandDescription] { get }
}
