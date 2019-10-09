import Cocoa

class LineDetailViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    var text = ""
    var font : NSFont? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.stringValue = self.text
        self.textField.font = self.font
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
