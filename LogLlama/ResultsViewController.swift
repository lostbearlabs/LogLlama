import Cocoa

/**
 This controller manages the panel that shows (filtered, colored) log lines produced by script execution.
 */
class ResultsViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var textCell: NSTextFieldCell!
    @IBOutlet weak var textColumn: NSTableColumn!

    var lines : [NSMutableAttributedString] = []
    var text : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self as? NSTableViewDelegate
        self.tableView.dataSource = self
        self.tableView.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.firstColumnOnlyAutoresizingStyle
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLogLinesUpdated(_:)), name: .LogLinesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
    }
    
    @objc private func onLogLinesUpdated(_ notification: Notification) {
        
        self.lines = []
        self.text = []

        if let update = notification.object as? LogLinesUpdate
        {
            for line in update.lines {
                if line.visible {
                    self.lines.append(line.getAttributedString())
                    self.text.append(line.text)
                }
            }
        }
        
        self.resizeColumn()
        self.tableView.noteNumberOfRowsChanged()
    }

    func resizeColumn() {
        var longest:CGFloat = 0
        for line in self.lines {
            let width = line.size().width
            if (longest < width) {
                longest = width
            }
        }

        self.textColumn.width = longest
        self.textColumn.minWidth = longest
    }
    
    @objc private func onFontSizeUpdated(_ notification: Notification) {
        if let update = notification.object as? FontSizeUpdate
        {
            if let origFont = self.textCell?.font {
                let newFont = NSFont(descriptor: origFont.fontDescriptor, size: CGFloat(update.size))
                self.textCell?.font = newFont
                self.tableView.rowHeight = CGFloat(update.size + 4)
                self.tableView.noteNumberOfRowsChanged()
            }
        }
    }
    
    @IBAction func onDoubleClick(_ sender: Any) {
        let viewController = self.storyboard?.instantiateController(withIdentifier: "LogDetail") as! LineDetailViewController
        let text = self.getSelectedText();
        if( text.count > 0 ) {
            viewController.setText(text: text)
            viewController.setFont(font: self.textCell!.font!)
            self.presentAsModalWindow(viewController)
        }
    }

    @objc func copy(_ sender: AnyObject?){

        let text = self.getSelectedText()

        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(text, forType:NSPasteboard.PasteboardType.string)
    }

    func getSelectedText() -> String {
        var text = ""
        for (_,idx) in (tableView?.selectedRowIndexes.enumerated())! {
            if( text != "" ) {
                text = text + "\n"
            }
            text = text + self.text[idx]
        }

        return text
    }

}

extension ResultsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        lines.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        lines[row]
    }
    
    func tableView(_: NSTableView, shouldEdit: NSTableColumn?, row: Int) -> Bool {
        false
    }
}
