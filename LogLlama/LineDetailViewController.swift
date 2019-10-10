import Cocoa

class LineDetailViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    var text = ""
    var font : NSFont? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.string = self.text
        self.textView.font = self.font
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
