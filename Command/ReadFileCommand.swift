import Cocoa
import Foundation
import PathKit

/// Inputs log lines one or more log files as specified by glob pattern.
class ReadFileCommand: ScriptCommand {
  var callback: ScriptCallback?
  var pattern: String = ""
  var files: [URL] = []

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let pattern = line.rest(), line.done() {
      self.pattern = pattern
      return true
    } else {
      log("expected 1 argument, file name pattern")
      return false
    }
  }

  func changesData() -> Bool {
    true
  }

  /// Populate self.files based on the file wildcard in in self.pattern.
  func listFiles() -> Bool {
    // Glob the pattern.
    self.files = Path.glob(self.pattern).map { URL(fileURLWithPath: $0.string) }

    // Unless the current process has already seen these files, the sandbox is going to
    // require that the user select them.
    let fileManager = FileManager.default
    if self.files.count == 0
      || !self.files.allSatisfy({ fileManager.isReadableFile(atPath: $0.path) })
    {
      self.files.removeAll()

      let dispatchGroup = DispatchGroup()
      dispatchGroup.enter()

      DispatchQueue.main.async {
        self.showFileChooserDialog(initialPath: self.pattern, dispatchGroup: dispatchGroup)
      }

      dispatchGroup.wait()
      log("\(self.files.count) file(s) selected by user")
      if self.files.count == 0 {
        log("no files selected")
        return false
      }
    }

    return true
  }

  func showFileChooserDialog(initialPath: String, dispatchGroup: DispatchGroup) {
    let openPanel = NSOpenPanel()

    // Configure the open panel
    openPanel.title = "Please select file(s) so LogLlama can access them."
    openPanel.showsResizeIndicator = true
    openPanel.showsHiddenFiles = false
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = true
    openPanel.allowsMultipleSelection = true

    // Set the initial path
    if let initialDirectoryURL = URL(string: initialPath) {
      openPanel.directoryURL = initialDirectoryURL
    }

    // Display the open panel
    openPanel.begin { (result) in
      if result == .OK && !openPanel.urls.isEmpty {
        for url in openPanel.urls {
          self.log("Selected file: \(url)")
          self.files.append(url)
        }
      } else {
        self.log("User canceled the selection.")
      }
      dispatchGroup.leave()
    }
  }

  func isFileReadable(file: Path) -> Bool {
    if !FileManager.default.isReadableFile(atPath: file.string) {
      log("Not a readable file: \(file.string)")
      return false
    }

    guard let fileHandle = FileHandle(forReadingAtPath: file.string) else {
      print("Unable to open file at path \(file.string)")
      return false
    }

    defer {
      fileHandle.closeFile()
    }

    return true
  }

  func readFileContents(file: URL) -> String? {
    do {
      let data = try String(contentsOfFile: file.path, encoding: .utf8)
      return data
    } catch {
      log("... error reading file: \(error)")
      return nil
    }
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {

    if !listFiles() {
      return false
    }

    let sortedPaths = self.sortFilesByCreationDate()

    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal

    for file in sortedPaths {
      log("Reading file \(file.path)")

      if let data = readFileContents(file: file) {
        let ar = data.components(separatedBy: .newlines)

        log("... processing \(withCommas(ar.count)) lines")

        var numIncluded = 0
        var numExcluded = 0
        var numRead = 0
        for ln in ar {
          var line = ln
          if self.lineWanted(line: line, runState: runState) {
            for it in runState.replace {
              line = line.replacingOccurrences(of: it.key, with: it.value)
            }

            // When loading single files, just use the line number from the file as the log line number.
            // When loading multiple files, increment from the end of each file so that line numbers are
            // unique and the original load order is preserved if sorting without fields.
            let lineNumber = logLines.count + 1

            let logLine = LogLine(text: line, lineNumber: lineNumber)
            logLines.append(logLine)
            numIncluded += 1
          } else {
            numExcluded += 1
          }
          numRead += 1
          if runState.limit > 0 && numRead >= runState.limit {
            log("... reached file limit of  \(withCommas(runState.limit)) lines")
            break
          }
          if numRead % 10000 == 0 {
            log("... \(withCommas(numRead))")
          }
        }
        log(
          "... read \(withCommas(ar.count)) lines, kept \(withCommas(numIncluded)), discarded \(withCommas(numExcluded))"
        )
      } else {
        return false
      }
    }
    return true
  }

  func lineWanted(line: String, runState: RunState) -> Bool {

    for regex in runState.filterRequired {
      if !regex.hasMatch(text: line) {
        return false
      }
    }

    for regex in runState.filterExcluded {
      if regex.hasMatch(text: line) {
        return false
      }
    }

    return true
  }

  func sortFilesByCreationDate() -> [URL] {
    return self.files.sorted(by: compareCreationDate)
  }

  func compareCreationDate(x: URL, y: URL) -> Bool {
    let dX = getCreationDate(path: x)
    let dY = getCreationDate(path: y)
    return dX.compare(dY) == ComparisonResult.orderedAscending
  }

  func getCreationDate(path: URL) -> Date {
    do {
      let attrs = try FileManager.default.attributesOfItem(atPath: path.path) as NSDictionary
      return attrs.fileCreationDate() ?? Date()
    } catch {
      return Date()
    }
  }

  func undoText() -> String {
    return ReadFileCommand.description[0].op
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .adding,
        op: "<",
        args: "file name/pattern",
        description: "load log lines from matching files in order created"
      )
    ]
  }

}
