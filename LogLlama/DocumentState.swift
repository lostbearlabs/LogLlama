import Foundation
import AppKit

/**
 Holds the AppDelegate's state with regard to whether the script file has been loaded/saved/modified.
 */
class DocumentState {
    
    static let INSTANCE = DocumentState()
    
    var currentFile : String?
    var textChanged = false
    var applicationLoaded = false

    func onApplicationLoaded() {
        self.applicationLoaded = true
    }

    func isApplicationLoaded() -> Bool {
        return self.applicationLoaded
    }

    func isFileLoaded() -> Bool {
        return self.currentFile != nil
    }

    func getCurrentFile() -> String {
        return self.currentFile!
    }

    func onFileOpened(file: String) {
        self.currentFile = file
        self.textChanged = false
    }

    func onNewFile() {
        self.currentFile = nil
        self.textChanged = false
    }

    func onFileSaved(file: String) {
        self.currentFile = file
        self.textChanged = false
    }

    func onFileSaved() {
        self.textChanged = false
    }

    func onTextChanged() {
        self.textChanged = true
    }

    func canDiscardText(action: String) -> Bool {
        if( !self.textChanged ) {
            return true
        }

        let alert = NSAlert()
        alert.messageText = "Discard changes?"
        alert.informativeText = "You have not saved your changes.  Do you still want to \(action)?"
        _ = alert.addButton(withTitle: "OK")
        _ = alert.addButton(withTitle: "Cancel")
        alert.alertStyle = NSAlert.Style.warning

        let rc = alert.runModal()
        return rc == NSApplication.ModalResponse.alertFirstButtonReturn
    }

    func getWindowTitle() -> String {
        if (self.currentFile == nil ) {
            return "LogLlama"
        } else {
            let name = NSString(string: self.currentFile!).lastPathComponent
            return "LogLlama - \(name)"
        }
    }

}
