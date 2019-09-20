import Cocoa

class ScriptViewController: NSViewController, NSTextViewDelegate, ScriptCallback {
    

    @IBOutlet var scriptText: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFileLoaded(_:)), name: .FileLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSaveFile(_:)), name: .SaveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNewFile(_:)), name: .NewFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRunClicked(_:)), name: .RunClicked, object: nil)
    }
    
    
    @objc private func onFileLoaded(_ notification: Notification) {
        if let path = notification.object as? String
        {
            do {
                let data = try NSString(contentsOfFile: path,
                                        encoding: String.Encoding.utf8.rawValue)
                
                self.scriptText.string = data as String
                
                NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))

            } catch {}
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
        NotificationCenter.default.post(name: .TextChanged, object: nil)
    }

    @objc private func onNewFile(_ notification: Notification) {
        self.scriptText.string = ""
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
    }
    
    @objc private func onRunClicked(_ notification: Notification) {
        let engine = ScriptEngine(callback: self)
        engine.run(script: self.scriptText.string)
    }
    
    func scriptStarted() {
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
    }
    
    func scriptUpdate(text: String) {
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(text: text))
    }
    
    func scriptDone(logLines: [LogLine]) {
        NotificationCenter.default.post(name: .LogLinesUpdated, object: LogLinesUpdate(lines: logLines))
    }

    
}
