import Cocoa

/**
 This controller manages the top-level application window.
 */
class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let thewindow = window!
        
        /// restore position
        thewindow.setFrameUsingName("LogLlamaMainWindow")
        self.windowFrameAutosaveName = "LogLlamaMainWindow"
    }

}
