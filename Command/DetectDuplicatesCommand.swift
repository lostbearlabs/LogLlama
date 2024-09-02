import Foundation

/// Processes log lines looking for duplicates and produces a summary by adding ersatz log lines at the top of the list.
///
/// When looking for matches, we replace phrases of the form "=value" and phrases the look like digits with placeholders, so that similar lines will match even if their details differ.
class DetectDuplicatesCommand: ScriptCommand {

  var callback: ScriptCallback?
  var threshold: Int = 0

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {
    true
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let text = line.pop(), line.done() {
      if let threshold = Int(text) {
        self.threshold = threshold
        return true
      }
      log("Not an integer: \(text)")
      return false
    } else {
      log("expected 1 integer argument, count threshold")
      return false
    }
  }

  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    var counts: [String: Int] = [:]

    log("Looking for lines that occur more that \(self.threshold) times")

    for line in logLines {
      let x = line.getAnonymousString()
      if counts.contains(where: { $0.key == x }) {
        counts[x] = counts[x]! + 1
      } else {
        counts[x] = 1
      }
    }

    var repeated: [String] = []
    for (text, count) in counts {
      if count > self.threshold {
        log("... found \(count) lines like: \(text)")
        let newLine = LogLine(text: "[\(count) LINES LIKE THIS] \(text)", lineNumber: 0)
        logLines.lines.insert(newLine, at: 0)
        repeated.append(text)
      }
    }

    return true
  }

  func undoText() -> String {
    return "\(DetectDuplicatesCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .analysis,
        op: "d",
        args: "N",
        description: "identify lines duplicated more than N times"
      )
    ]
  }

}
