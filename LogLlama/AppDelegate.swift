import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var currentFile : String?
    var textChanged = false
    var fontSize = 14
    var logFileToAnalyze : String?
    var loaded = false
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChanged(_:)), name: .ScriptTextChanged, object: nil)
        self.sendFontSizeUpdate()
        
        if( self.logFileToAnalyze != nil ) {
            NotificationCenter.default.post(name: .AnalyzeLogFile, object: self.logFileToAnalyze)
            NotificationCenter.default.post(name: .RunClicked, object: nil)
        }
        
        self.loaded = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
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
                currentFile = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if( self.loaded ) {
            NotificationCenter.default.post(name: .OpenScriptFile, object: filename)
            // the user has clicked the open-recent menu to open a script
        } else {
            // the user has opened a log file via finder; we'll construct a script to process it later once
            // we are loading
            self.logFileToAnalyze = filename
        }
        return true
    }

    @IBAction func newFile(_ sender: Any) {
        if( self.checkSave() ) {
            NotificationCenter.default.post(name: .NewScriptFile, object: nil)
            NotificationCenter.default.post(name: .LogLinesUpdated, object: nil)
            self.textChanged = false
            self.currentFile = nil
        }
    }
    
    @IBAction func closeFile(_ sender: Any) {
    }
    
    @IBAction func saveFile(_ sender: Any) {
        if( self.currentFile == nil ) {
            self.saveFileAs(sender)
        } else {
            NotificationCenter.default.post(name: .SaveScriptFile, object: self.currentFile)
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
                self.currentFile = path
                self.textChanged = false
            }
        }
    }
 
    
    @objc private func onTextChanged(_ notification: Notification) {
        if( !self.textChanged ) {
            self.textChanged = true
        }
    }
    
    func checkSave() -> Bool {
        if( self.textChanged ) {
            // TODO: how to prompt for save?
        }
        
        return true
    }
    
    @IBAction func onRunClicked(_ sender: Any) {
        NotificationCenter.default.post(name: .RunClicked, object: nil)
    }
    
    func sendFontSizeUpdate() {
        NotificationCenter.default.post(name: .FontSizeUpdated, object: FontSizeUpdate(size: self.fontSize))
    }
    
    @IBAction func onFontBigger(_ sender: Any) {
        self.fontSize += 1
        sendFontSizeUpdate()
    }
    
    @IBAction func onFontSmaller(_ sender: Any) {
        self.fontSize -= 1
        sendFontSizeUpdate()
    }
    
    @IBAction func onHelpClicked(_ sender: Any) {
        if let url = URL(string: "https://github.com/lostbearlabs/LogLlama") {
            NSWorkspace.shared.open(url)
        }
    }
    
    
}

