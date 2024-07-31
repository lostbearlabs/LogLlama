import Cocoa

class LineDetailViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!
    var text = ""
    var font : NSFont? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.string = self.text
        self.textView.font = self.font
        
        // overlay parent
        if let window = NSApplication.shared.windows.first {
            let rect = window.frame
            let xMargin = rect.width * 0.10
            let yMargin = rect.height * 0.10
            let size = NSSize(width: rect.width - xMargin, height: rect.height - yMargin)
            self.view.setFrameSize(size)
        }
    }
    
    func setText(text: String) {
        self.text = text
    }
    
    func setFont(font: NSFont) {
        self.font = font
    }
    
    @IBAction func onDoneClicked(_ sender: Any) {
        self.dismiss(nil)
    }
    
}
