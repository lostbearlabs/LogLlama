import Cocoa

/**
 This controller manages the panel with the script in it.  The controller is responsible for loading and saving script text and for executing script.
 */
class ScriptViewController: NSViewController, NSTextViewDelegate, ScriptCallback {
    

    @IBOutlet var scriptText: NSTextView!
    var running = false
    var lastResults : [LogLine] = []
    let maxUndo = 5
    var undoResults : [LogLinesUpdate] = []
    var runState = RunState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFileLoaded(_:)), name: .OpenScriptFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSaveFile(_:)), name: .SaveScriptFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNewFile(_:)), name: .NewScriptFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRunClicked(_:)), name: .RunClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUndoClicked(_:)), name: .UndoClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onShouldAnalyzeLogFile(_:)), name: .AnalyzeLogFile, object: nil)

        self.scriptText.delegate = self
    }

    @objc private func onFontSizeUpdated(_ notification: Notification) {
        if let update = notification.object as? FontSizeUpdate
        {
            if let origFont = self.scriptText.font {
                let newFont = NSFont(descriptor: origFont.fontDescriptor, size: CGFloat(update.size))
                self.scriptText.font = newFont
            }
        }
    }

    @objc private func onFileLoaded(_ notification: Notification) {
        if let path = notification.object as? String
        {
            do {
                let data = try NSString(contentsOfFile: path,
                                        encoding: String.Encoding.utf8.rawValue)
                
                self.scriptText.string = data as String
                
                NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))

                self.undoResults.removeAll()
                self.sendUndoState()

            } catch {}
        }
    }

    @objc private func onShouldAnalyzeLogFile(_ notification: Notification) {
        if let path = notification.object as? String
        {
            // create a new script file that references the specified log file
            self.scriptText.string = "< \(path)\n"
            NotificationCenter.default.post(name: .ScriptTextChanged, object: nil)
        }
    }

    
    @objc private func onSaveFile(_ notification: Notification) {
        if let path = notification.object as? String
        {
            do {
                let data = self.scriptText.string
                let url = URL( fileURLWithPath: path)
                try data.write(to: url, atomically: true, encoding:
                    String.Encoding.utf8 )
            } catch {
                print("Unexpected error saving file: \(error).")
            }
        }
    }
    
    func textDidChange(_ notification: Notification) {
        NotificationCenter.default.post(name: .ScriptTextChanged, object: nil)
    }

    @objc private func onNewFile(_ notification: Notification) {
        self.scriptText.string = ""
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
        self.undoResults.removeAll()
        self.sendUndoState()
    }
    
    @objc private func onRunClicked(_ notification: Notification) {
        if( !running ) {
            running = true
            
            let (script, selection) = self.getTextToRun();
            if( !selection ) {
                self.lastResults = []
            }
            
            let dispatchQueue = DispatchQueue(label: "ScriptEngine", qos: .background)
            dispatchQueue.async{
                let engine = ScriptEngine(callback: self)
                engine.setInitialLines(lines: self.lastResults)
                engine.setRunState(runState: self.runState)
                engine.run(script: script)
            }
        }
    }
    
    private func getTextToRun() -> (String, Bool) {
        let ranges = scriptText.selectedRanges
        if( ranges.count==0 ) {
            return (self.scriptText.string, false)
        }
        let text = self.scriptText.string as NSString?
        let range = ranges[0] as! NSRange
        if (range.length==0 ) {
            return (self.scriptText.string, false)
        }
        let substr = (text?.substring(with: range))!
        return (substr, true)
    }
    
    func scriptStarted() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
        }
    }
    
    func scriptUpdate(text: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(text: text))
        }
    }
    
    func scriptDone(logLines: [LogLine]) {
        DispatchQueue.main.async {
            self.lastResults = logLines
            let update = LogLinesUpdate(lines: logLines)
            NotificationCenter.default.post(name: .LogLinesUpdated, object: update)
            self.running = false


            while self.undoResults.count > self.maxUndo {
                self.undoResults.remove(at: 0)
            }
            self.undoResults.append(update)
            self.sendUndoState()
        }
    }

    @objc private func onUndoClicked(_ notification: Notification) {
        if let _ = self.undoResults.popLast() {
            if let update = self.undoResults.last {
                NotificationCenter.default.post(name: .LogLinesUpdated, object: update)

                self.lastResults.removeAll()
                for line in update.lines {
                    self.lastResults.append(line)
                }
            }
        }
        self.sendUndoState()
    }

    func sendUndoState() {
        let enabled = self.undoResults.count > 0
        NotificationCenter.default.post(name: .CanUndoUpdated, object: enabled)
    }
}
