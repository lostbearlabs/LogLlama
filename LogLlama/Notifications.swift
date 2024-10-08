import Foundation

/// Messages sent among the controllers.
extension Notification.Name {
  static let OpenScriptFile = Notification.Name("OpenScriptFile")  // payload = script file path (String)
  static let AnalyzeLogFile = Notification.Name("AnalyzeLogFile")  // payload = log file path (String)
  static let SaveScriptFile = Notification.Name("SaveScriptFile")  // payload = script file path (String)
  static let ScriptTextChanged = Notification.Name("ScriptTextChanged")  // payload null
  static let NewScriptFile = Notification.Name("NewScriptFile")  // payload null
  static let RunClicked = Notification.Name("RunClicked")  // payload null
  static let ClearAndRunClicked = Notification.Name("ClearAndRunClicked")  // payload null
  static let ScriptProcessingUpdate = Notification.Name("ScriptProcessingUpdate")  // payload ScriptProcessingUpdate
  static let LogLinesUpdated = Notification.Name("LogLinesUpdated")  // payload LogLinesUpdate
  static let FontSizeUpdated = Notification.Name("FontSizeUpdated")  // payload FontSizeUpdate
  static let CanUndoUpdated = Notification.Name("CanUndoUpdated")  // payload UndoUpdate
  static let UndoClicked = Notification.Name("UndoClicked")  // payload null
  static let ShowLineDetailClicked = Notification.Name("ShowLineDetailClicked")  // payload null
  static let RunStarted = Notification.Name("RunStarted")  // payload null
  static let RunFinished = Notification.Name("RunFinished")  // payload null
  static let PopulateDemoText = Notification.Name("PopulateDemoText")  // payload null
  static let LoadLogFile = Notification.Name("LoadLogFile")  // payload = log file path (String)

}
