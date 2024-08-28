import Cocoa

/// This controller manages the panel that shows (filtered, colored) log lines produced by script execution.
class ResultsViewController: NSViewController {

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var textCell: NSTextFieldCell!
  @IBOutlet weak var lineNumberCell: NSTextFieldCell!
  @IBOutlet weak var textColumn: NSTableColumn!
  @IBOutlet weak var lineNumberColumn: NSTableColumn!

  @IBOutlet weak var searchField: NSSearchField!

  var logLines: LogLineArray = LogLineArray()
  var longestLineLength = 1

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.delegate = self as? NSTableViewDelegate
    self.tableView.dataSource = self
    self.tableView.columnAutoresizingStyle =
      NSTableView.ColumnAutoresizingStyle.firstColumnOnlyAutoresizingStyle

    NotificationCenter.default.addObserver(
      self, selector: #selector(onLogLinesUpdated(_:)), name: .LogLinesUpdated, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onShowLineDetailClicked(_:)), name: .ShowLineDetailClicked,
      object: nil)
  }

  @objc private func onShowLineDetailClicked(_ notification: Notification) {
    self.onDoubleClick(self)
  }

  @objc private func onLogLinesUpdated(_ notification: Notification) {

    self.logLines = LogLineArray()

    if let update = notification.object as? LogLinesUpdate {
      self.longestLineLength = 1
      for line in update.lines {
        if line.visible {
          self.logLines.append(line)
          self.longestLineLength = max(self.longestLineLength, line.text.count)
        }
      }
    }

    self.resizeColumn()
  }

  func resizeColumn() {
    // It would be inefficient to go through every line, apply the current font, and then check
    // its width to find the maximum.  Instead, just use a wide character (W) and multiply its
    // width by the length of the longest line.
    let stringWithAttribute = NSAttributedString(
      string: "W",
      attributes: [NSAttributedString.Key.font: self.textCell.font!])
    let width = CGFloat(self.longestLineLength) * stringWithAttribute.size().width

    self.textColumn.width = width
    self.textColumn.minWidth = width

    self.tableView.noteNumberOfRowsChanged()
  }

  @objc private func onFontSizeUpdated(_ notification: Notification) {
    if let update = notification.object as? FontSizeUpdate {
      if let origFont = self.textCell?.font {
        let newFont = NSFont(descriptor: origFont.fontDescriptor, size: CGFloat(update.size))
        self.textCell?.font = newFont
        self.tableView.rowHeight = CGFloat(update.size + 4)
        self.resizeColumn()
      }
    }
  }

  @IBAction func onDoubleClick(_ sender: Any) {
    let viewController =
      self.storyboard?.instantiateController(withIdentifier: "LogDetail")
      as! LineDetailViewController

    let text = self.getSelectedText(includeFields: true)
    if text.count > 0 {
      viewController.setText(text: text)
      viewController.setFont(font: self.textCell!.font!)
      self.presentAsModalWindow(viewController)
    }
  }

  @objc func copy(_ sender: AnyObject?) {

    let text = self.getSelectedText(includeFields: false)

    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.setString(text, forType: NSPasteboard.PasteboardType.string)
  }

  func getSelectedText(includeFields: Bool) -> String {
    var text = ""
    for (_, idx) in (tableView?.selectedRowIndexes.enumerated())! {
      if text != "" {
        text = text + "\n"
      }
      text = text + self.logLines[idx].text

      if includeFields && !self.logLines[idx].namedFieldValues.isEmpty {
        text = text + "\n\n-----------  \n"
        text =
          text + self.formatFieldListForLine(namedFieldValues: self.logLines[idx].namedFieldValues)
        text = text + "-----------  \n"
      }
    }

    return text
  }

  func formatFieldListForLine(namedFieldValues: [String: String]) -> String {
    var text = ""
    let keys = namedFieldValues.keys.sorted()
    for key in keys {
      let val = namedFieldValues[key]!
      text = text + "\(key) = \(val)\n"
    }
    return text
  }

  func getSelectedRow() -> Int {
    for (_, idx) in (tableView?.selectedRowIndexes.enumerated())! {
      return idx
    }
    return -1
  }

  @IBAction func onSearchTextChanged(_ sender: Any) {
    let sel = self.getSelectedRow() + 1
    self.doFind(searchText: self.searchField.stringValue, startPos: sel, incr: 1)
  }

  @IBAction func onClickedNext(_ sender: Any) {
    let sel = self.getSelectedRow() + 1
    self.doFind(searchText: self.searchField.stringValue, startPos: sel, incr: 1)
  }

  @IBAction func onClickedPrev(_ sender: Any) {
    var sel = getSelectedRow()
    if sel < 0 {
      sel = self.logLines.count
    }
    self.doFind(searchText: self.searchField.stringValue, startPos: sel - 1, incr: -1)
  }

  func doFind(searchText: String, startPos: Int, incr: Int) {
    if searchText == "" {
      return
    }

    for i in 0...self.logLines.count {
      let x = (startPos + i * incr + self.logLines.count) % self.logLines.count
      if self.logLines[x].text.lowercased().contains(searchText.lowercased()) {
        let indexSet = IndexSet(integer: x)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
        self.tableView?.scrollRowToVisible(x)
        return
      }
    }
  }

}

extension ResultsViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    logLines.count
  }

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int)
    -> Any?
  {
    if tableColumn == lineNumberColumn {
      String(logLines[row].lineNumber)
    } else {
      logLines[row].getAttributedString()
    }
  }

  func tableView(_: NSTableView, shouldEdit: NSTableColumn?, row: Int) -> Bool {
    false
  }
}
