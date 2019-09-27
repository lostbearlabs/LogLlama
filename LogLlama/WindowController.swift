import Cocoa

/**
 This controller manages the top-level application window.
 */
class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // restore position
        window!.setFrameUsingName("LogLlamaMainWindow")
        self.windowFrameAutosaveName = "LogLlamaMainWindow"
    }

}
