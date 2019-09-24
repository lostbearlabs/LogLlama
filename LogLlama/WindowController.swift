import Cocoa

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let thewindow = window!
        
        /// restore position
        thewindow.setFrameUsingName("LogLlamaMainWindow")
        self.windowFrameAutosaveName = "LogLlamaMainWindow"
    }

}
