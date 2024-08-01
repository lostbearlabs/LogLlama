import Foundation
import PathKit
import Cocoa

/**
 Inputs log lines one or more log files as specified by glob pattern.
 */
class ReadFileCommand : ScriptCommand {
    var callback : ScriptCallback
    var pattern : String
    var files : [URL] = []
    var nameValueRegex:NSRegularExpression?
    
    init(callback: ScriptCallback, pattern: String) {
        self.callback = callback
        self.pattern = pattern
        
        do {
            // parse the regex for efficient use later
            let nameValuePattern="(\\w+)=(\\w+)"
            try self.nameValueRegex = NSRegularExpression(pattern: nameValuePattern, options: [])
        } catch {
            print("ERROR IN CANNED REGEX \(error)")
        }
    }
    
    func validate() -> Bool {
        self.files = Path.glob(self.pattern).map { URL(fileURLWithPath: $0.string)}
        let fileManager = FileManager.default
        if self.files.count==0 || !self.files.allSatisfy({ fileManager.isReadableFile(atPath: $0.path)}) {
            self.files.removeAll()
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            DispatchQueue.main.async {
                self.showFileChooserDialog(initialPath: self.pattern, dispatchGroup: dispatchGroup)
            }
            
            dispatchGroup.wait()
            self.callback.scriptUpdate(text: "\(self.files.count) file(s) selected by user")
        }
        
        if self.files.count == 0 {
            self.callback.scriptUpdate(text: "no file(s) found that look like: \(self.pattern)")
            return false
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
                    self.callback.scriptUpdate(text: "Selected file: \(url)")
                    self.files.append(url)
                }
            } else {
                self.callback.scriptUpdate(text: "User canceled the selection.")
            }
            dispatchGroup.leave()
        }
    }
    
    func changesData() -> Bool {
        true
    }
    
    func isFileReadable(file: Path) -> Bool {
        if( !FileManager.default.isReadableFile(atPath: file.string)) {
            self.callback.scriptUpdate(text: "Not a readable file: \(file.string)")
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
            self.callback.scriptUpdate(text: "... error reading file: \(error)")
            return nil
        }
    }
    
    func run(logLines : inout [LogLine], runState : inout RunState) -> Bool {
        let sortedPaths = self.sortFilesByCreationDate()
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        for file in sortedPaths {
            self.callback.scriptUpdate(text: "Reading file \(file.path)")
            
            if let data = readFileContents(file: file) {
                let ar = data.components(separatedBy: .newlines)
                
                self.callback.scriptUpdate(text: "... processing \(withCommas(ar.count)) lines")
                
                var numIncluded = 0
                var numExcluded = 0
                var numRead = 0
                for ln in ar {
                    var line = ln
                    if( self.lineWanted(line: line, runState: runState)) {
                        for it in runState.replace {
                            line = line.replacingOccurrences(of: it.key, with: it.value)
                        }
                        let logLine = LogLine(text: line, lineNumber: numRead)
                        logLines.append( logLine )
                        numIncluded += 1
                    } else {
                        numExcluded += 1
                    }
                    numRead += 1
                    if( runState.limit>0 && numRead >= runState.limit) {
                        self.callback.scriptUpdate(text: "... reached file limit of  \(withCommas(runState.limit)) lines")
                        break
                    }
                    if( numRead%10000 == 0) {
                        self.callback.scriptUpdate(text: "... \(withCommas(numRead))")
                    }
                }
                self.callback.scriptUpdate(text: "... read \(withCommas(ar.count)) lines, kept \(withCommas(numIncluded)), discarded \(withCommas(numExcluded))")
            } else {
                return false
            }
        }
        return true
    }
    
    func lineWanted(line : String, runState: RunState) -> Bool {
        
        for regex in runState.filterRequired {
            if !self.doesMatch(line: line, regex: regex) {
                return false
            }
        }
        
        for regex in runState.filterExcluded {
            if self.doesMatch(line: line, regex: regex) {
                return false
            }
        }
        
        return true
    }
    
    func doesMatch(line: String, regex: NSRegularExpression) -> Bool {
        let results = regex.matches(in: line,
                                    range: NSRange(line.startIndex..., in: line))
        
        return results.count > 0
    }
    
    func sortFilesByCreationDate() -> [URL] {
        return self.files.sorted(by: compareCreationDate)
    }
    
    func compareCreationDate(x: URL, y:URL) -> Bool {
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
    
    func description() -> String {
        return "<"
    }

    
}
