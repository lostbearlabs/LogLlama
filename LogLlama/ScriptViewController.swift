import Cocoa

/// This controller manages the panel with the script in it.  The controller is responsible for loading and saving script text and for executing script.
class ScriptViewController: NSViewController, NSTextViewDelegate, ScriptCallback {

  @IBOutlet var scriptText: NSTextView!
  var running = false
  var lastResults: LogLineArray = LogLineArray()
  var curUndoLines = 0
  let maxUndoLines = 10_000_000
  var undoResults: [UndoState] = []
  var runState = RunState()

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(
      self, selector: #selector(onFileLoaded(_:)), name: .OpenScriptFile, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onSaveFile(_:)), name: .SaveScriptFile, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onNewFile(_:)), name: .NewScriptFile, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onRunClicked(_:)), name: .RunClicked, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onClearAndRunClicked(_:)), name: .ClearAndRunClicked, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onUndoClicked(_:)), name: .UndoClicked, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onShouldAnalyzeLogFile(_:)), name: .AnalyzeLogFile, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onRunStarted(_:)), name: .RunStarted, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onRunFinished(_:)), name: .RunFinished, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onPopulateDemoText(_:)), name: .PopulateDemoText, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(onLoadLogFile(_:)), name: .LoadLogFile, object: nil)

    self.scriptText.delegate = self
  }

  @IBAction func onRunStarted(_ sender: Any) {
    enableUI(enabled: false)
  }

  @IBAction func onRunFinished(_ sender: Any) {
    enableUI(enabled: true)
  }

  func enableUI(enabled: Bool) {
    self.scriptText.isEditable = enabled
  }

  @objc private func onFontSizeUpdated(_ notification: Notification) {
    if let update = notification.object as? FontSizeUpdate {
      if let origFont = self.scriptText.font {
        let newFont = NSFont(descriptor: origFont.fontDescriptor, size: CGFloat(update.size))
        self.scriptText.font = newFont
      }
    }
  }

  @objc private func onLoadLogFile(_ notification: Notification) {
    if let path = notification.object as? String {
      self.runScript(script: "< \(path)")
    }
  }

  @objc private func onFileLoaded(_ notification: Notification) {
    if let path = notification.object as? String {
      do {
        let data = try NSString(
          contentsOfFile: path,
          encoding: String.Encoding.utf8.rawValue)

        self.scriptText.string = data as String

        NotificationCenter.default.post(
          name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))

        self.undoResults.removeAll()
        self.curUndoLines = 0
        self.sendUndoState()

      } catch {}
    }
  }

  @objc private func onShouldAnalyzeLogFile(_ notification: Notification) {
    if let path = notification.object as? String {
      // create a new script file that references the specified log file
      self.scriptText.string = "< \(path)\n"
      NotificationCenter.default.post(name: .ScriptTextChanged, object: nil)
    }
  }

  @objc private func onSaveFile(_ notification: Notification) {
    if let path = notification.object as? String {
      do {
        let data = self.scriptText.string
        let url = URL(fileURLWithPath: path)
        try data.write(
          to: url, atomically: true,
          encoding:
            String.Encoding.utf8)
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
    NotificationCenter.default.post(
      name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
    self.undoResults.removeAll()
    self.curUndoLines = 0
    self.sendUndoState()
  }

  @objc private func onRunClicked(_ notification: Notification) {
    let (script, _) = self.getTextToRun()
    self.runScript(script: script)
  }

  @objc private func onClearAndRunClicked(_ notification: Notification) {
    let (script, _) = self.getTextToRun()
    self.lastResults = LogLineArray()
    self.runScript(script: script)
  }

  private func runScript(script: String) {
    if !running {
      running = true

      let dispatchQueue = DispatchQueue(label: "ScriptEngine", qos: .background)
      dispatchQueue.async {
        let engine = ScriptEngine(callback: self)
        engine.setInitialLines(lines: self.lastResults)
        engine.setRunState(runState: self.runState)
        engine.run(script: script)
      }
    }
  }

  private func getTextToRun() -> (String, Bool) {
    let ranges = scriptText.selectedRanges
    if ranges.count == 0 {
      return (self.scriptText.string, false)
    }
    let text = self.scriptText.string as NSString?
    let range = ranges[0] as! NSRange
    if range.length == 0 {
      return (self.scriptText.string, false)
    }
    let substr = (text?.substring(with: range))!
    return (substr, true)
  }

  func scriptStarted() {
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: .RunStarted, object: nil)
      NotificationCenter.default.post(
        name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(clear: true))
    }
  }

  func scriptUpdate(text: String) {
    DispatchQueue.main.async {
      NotificationCenter.default.post(
        name: .ScriptProcessingUpdate, object: ScriptProcessingUpdate(text: text))
    }
  }

  func scriptDone(logLines: LogLineArray, op: String?) {
    DispatchQueue.main.async {
      self.lastResults = logLines
      let update = LogLinesUpdate(lines: logLines)
      let runState = self.runState.clone()
      let undoState = UndoState(op: op, lines: logLines, runState: runState)
      NotificationCenter.default.post(name: .LogLinesUpdated, object: update)
      self.running = false

      while self.curUndoLines > self.maxUndoLines {
        let dropped = self.undoResults.remove(at: 0)
        self.curUndoLines -= dropped.count
      }

      self.undoResults.append(undoState)
      self.curUndoLines += undoState.lines.count

      self.sendUndoState()

      NotificationCenter.default.post(name: .RunFinished, object: nil)
    }
  }

  @objc private func onUndoClicked(_ notification: Notification) {
    if let dropped = self.undoResults.popLast() {
      self.curUndoLines -= dropped.lines.count

      if let undoState = self.undoResults.last {
        NotificationCenter.default.post(
          name: .LogLinesUpdated, object: LogLinesUpdate(lines: undoState.lines))

        self.lastResults.clear()
        for line in undoState.lines {
          self.lastResults.append(line)
        }

        self.runState = undoState.runState
      } else {
        NotificationCenter.default.post(
          name: .LogLinesUpdated, object: LogLinesUpdate(lines: LogLineArray()))
        self.lastResults.clear()
      }
    }
    self.sendUndoState()
  }

  func sendUndoState() {
    let enabled = self.undoResults.count > 0
    let op = self.undoResults.last?.op ?? nil
    let update = UndoUpdate(enabled: enabled, op: op)

    print(
      "undoResults.count=\(undoResults.count), undo enabled=\(enabled), op=\(op ?? "?"), curUndoLines=\(self.curUndoLines)"
    )
    NotificationCenter.default.post(name: .CanUndoUpdated, object: update)
  }

  @objc private func onPopulateDemoText(_ notification: Notification) {
    self.scriptText.string = demoScriptText
  }

}
