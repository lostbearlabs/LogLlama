import Cocoa

/**
 The app delegate -- this class launches the application and handles top-level menu commands.
 */
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var fontSize = 14
    var logFileToAnalyze : String?
    var wasUndoEnabled: Bool = true

    @IBOutlet weak var mnuUndo: NSMenuItem!
    @IBOutlet weak var mnuExecute: NSMenuItem!
    @IBOutlet weak var mnuEdit: NSMenuItem!
    @IBOutlet weak var mnuFile: NSMenuItem!

    @IBAction func onClickUndo(_ sender: Any) {
        NotificationCenter.default.post(name: .UndoClicked, object: nil)
    }

    @objc private func onCanUndoUpdated(_ notification: Notification) {
        let enabled = notification.object as! Bool
        self.mnuUndo.isEnabled = enabled
        wasUndoEnabled = enabled
    }

    @IBAction func onRunStarted(_ sender: Any) {
        print("run started")
        enableUI(enabled: false)
        NSCursor.operationNotAllowed.push()
    }
    
    @IBAction func onRunFinished(_ sender: Any) {
        print("run finished")
        enableUI(enabled: true)
        NSCursor.operationNotAllowed.pop()
    }

    func enableUI(enabled: Bool) {
        self.mnuUndo.isEnabled = enabled && wasUndoEnabled
        self.mnuExecute.isEnabled = enabled
        self.mnuEdit.isEnabled = enabled
        self.mnuFile.isEnabled = enabled
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChanged(_:)), name: .ScriptTextChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCanUndoUpdated(_:)), name: .CanUndoUpdated, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onRunStarted(_:)), name: .RunStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRunFinished(_:)), name: .RunFinished, object: nil)
        
        self.loadFontSize()
        self.sendFontSizeUpdate()
        
        if( self.logFileToAnalyze != nil ) {
            NotificationCenter.default.post(name: .AnalyzeLogFile, object: self.logFileToAnalyze)
            NotificationCenter.default.post(name: .RunClicked, object: nil)
        }

        DocumentState.INSTANCE.onApplicationLoaded()
        self.updateWindowTitle()
    
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if( DocumentState.INSTANCE.canDiscardText(action: "exit")) {
            return NSApplication.TerminateReply.terminateNow;
        }
        return NSApplication.TerminateReply.terminateCancel;
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
          return true
    }

    @IBAction func openFile(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                NotificationCenter.default.post(name: .OpenScriptFile, object: path)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: path))
                DocumentState.INSTANCE.onFileOpened(file: path)
                self.updateWindowTitle()
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if( DocumentState.INSTANCE.isApplicationLoaded() ) {
            if( DocumentState.INSTANCE.canDiscardText(action: "load file")) {
                // the user has clicked the open-recent menu to open a script
                NotificationCenter.default.post(name: .OpenScriptFile, object: filename)
                DocumentState.INSTANCE.onFileOpened(file: filename)
                self.updateWindowTitle()
            }
        } else {
            // the user has opened a log file via finder; we'll construct a script to process it later once
            // we are loading
            self.logFileToAnalyze = filename
            DocumentState.INSTANCE.onApplicationLoaded()
            DocumentState.INSTANCE.onTextChanged()
            self.updateWindowTitle()
        }
        return true
    }

    @IBAction func newFile(_ sender: Any) {
        if( DocumentState.INSTANCE.canDiscardText(action: "create a new file") ) {
            NotificationCenter.default.post(name: .NewScriptFile, object: nil)
            NotificationCenter.default.post(name: .LogLinesUpdated, object: nil)
            DocumentState.INSTANCE.onNewFile()
            self.updateWindowTitle()
        }
    }
    
    @IBAction func closeFile(_ sender: Any) {
    }
    
    @IBAction func saveFile(_ sender: Any) {
        if( !DocumentState.INSTANCE.isFileLoaded() ) {
            self.saveFileAs(sender)
        } else {
            NotificationCenter.default.post(name: .SaveScriptFile, object: DocumentState.INSTANCE.getCurrentFile())
            DocumentState.INSTANCE.onFileSaved()
            self.updateWindowTitle()
        }
    }
    
    @IBAction func saveFileAs(_ sender: Any) {
        let dialog = NSSavePanel()
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canCreateDirectories    = true;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                NotificationCenter.default.post(name: .SaveScriptFile, object: path)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: path))
                DocumentState.INSTANCE.onFileSaved(file: path)
                self.updateWindowTitle()
            }
        }
    }

    
    @objc private func onTextChanged(_ notification: Notification) {
        DocumentState.INSTANCE.onTextChanged()
        self.updateWindowTitle()
    }
    

    @IBAction func onRunClicked(_ sender: Any) {
        NotificationCenter.default.post(name: .RunClicked, object: nil)
    }
    
    func sendFontSizeUpdate() {
        NotificationCenter.default.post(name: .FontSizeUpdated, object: FontSizeUpdate(size: self.fontSize))
    }
    
    @IBAction func onFontBigger(_ sender: Any) {
        self.fontSize += 1
        self.saveFontSize()
        sendFontSizeUpdate()
    }
    
    @IBAction func onFontSmaller(_ sender: Any) {
        self.fontSize -= 1
        self.saveFontSize()
        sendFontSizeUpdate()
    }
    
    private func loadFontSize() {
        let fontSize = UserDefaults.standard.integer(forKey: "FontSize")
        if fontSize > 0 {
            self.fontSize = fontSize
        }
    }
    
    private func saveFontSize() {
        UserDefaults.standard.set(self.fontSize, forKey: "FontSize")
    }
    
    @IBAction func onHelpClicked(_ sender: Any) {
        if let url = URL(string: "https://github.com/lostbearlabs/LogLlama") {
            NSWorkspace.shared.open(url)
        }
    }

    private func updateWindowTitle() {
        let title = DocumentState.INSTANCE.getWindowTitle()
        NSApplication.shared.windows.first!.title = title
    }
    
    @IBAction func onShowLineDetailClicked(_ sender: Any) {
        NotificationCenter.default.post(name: .ShowLineDetailClicked, object: nil)
    }

}

