import Cocoa

class ScriptViewController: NSViewController, NSTextViewDelegate, ScriptCallback {
    

    @IBOutlet var scriptText: NSTextView!
    var running = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFileLoaded(_:)), name: .FileLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSaveFile(_:)), name: .SaveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNewFile(_:)), name: .NewFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRunClicked(_:)), name: .RunClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
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
        if( !running ) {
            running = true
            let dispatchQueue = DispatchQueue(label: "ScriptEngine", qos: .background)
            let script = self.scriptText.string
            dispatchQueue.async{
                let engine = ScriptEngine(callback: self)
                engine.run(script: script)
            }
        }
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
            NotificationCenter.default.post(name: .LogLinesUpdated, object: LogLinesUpdate(lines: logLines))
            self.running = false
        }
    }

    
}
