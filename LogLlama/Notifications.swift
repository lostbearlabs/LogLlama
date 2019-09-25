import Foundation

import Foundation

extension Notification.Name {
    static let FileLoaded = Notification.Name("FileLoaded")     // payload = path (String)
    static let SaveFile = Notification.Name("SaveFile")         // payload null
    static let TextChanged = Notification.Name("TextChanged")   // payload null
    static let NewFile = Notification.Name("NewFile")           // payload null
    static let RunClicked = Notification.Name("RunClicked")     // payload null
    static let ScriptProcessingUpdate = Notification.Name("ScriptProcessingUpdate") // payload ScriptProcessingUpdate
    static let LogLinesUpdated = Notification.Name("LogLinesUpdated")    // payload LogLinesUpdate
    static let FontSizeUpdated = Notification.Name("FontSizeUpdated")    // payload FontSizeUpdate
}
