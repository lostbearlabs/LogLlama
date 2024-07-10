import Cocoa

/**
 This controller manages the top-level application window.
 */
class WindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // restore position
        window!.setFrameUsingName("LogLlamaMainWindow")
        self.windowFrameAutosaveName = "LogLlamaMainWindow"
        
        self.window?.isReleasedWhenClosed = true
        
        self.shouldCloseDocument = true
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if( DocumentState.INSTANCE.canDiscardText(action: "exit")) {
            // Pretend like we saved the file, so the terminate handler doesn't prompt a second time.
            DocumentState.INSTANCE.onFileSaved()
            return true
        }
        
        return false
    }
    

}
