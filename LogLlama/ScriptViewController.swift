import Cocoa

class ScriptViewController: NSViewController, NSTextViewDelegate {

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
            NSLog(path)
            
            do {
                let data = try NSString(contentsOfFile: path,
                                        encoding: String.Encoding.utf8.rawValue)
                
                // If a value was returned, print it.
                print(data)
                
                self.scriptText.string = data as String
                
                print("loaded script from \(data)")

            } catch {}
        }
    }

    @objc private func onSaveFile(_ notification: Notification) {
        if let path = notification.object as? String
        {
            NSLog(path)
            
            do {
                let data = self.scriptText.string
                let url = URL( fileURLWithPath: path)
                try data.write(to: url, atomically: true, encoding:
                String.Encoding.utf8 )
                print("saved script to \(url)")
            } catch {
                print("Unexpected error saving file: \(error).")
            }
        }
    }
    
    func textDidChange(_ notification: Notification) {
        NotificationCenter.default.post(name: .TextChanged, object: nil)
    }

    @objc private func onNewFile(_ notification: Notification) {
        print("cleared text for new file")
        self.scriptText.string = ""
    }
    
    @objc private func onRunClicked(_ notification: Notification) {
        print("RUNNNING SCRIPT")

        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(text: "this is line one"))
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(text: "now there are two lines"))
        NotificationCenter.default.post(name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(text: "third line is the last one"))

        let logLinesUpdate = LogLinesUpdate()
        NotificationCenter.default.post(name: .LogLinesUpdated, object: logLinesUpdate)
    }
    
}
