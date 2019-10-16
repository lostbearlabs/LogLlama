import Foundation
import PathKit

/**
 Inputs log lines one or more log files as specified by glob pattern.
 */
class ReadFileCommand : ScriptCommand {
    var callback : ScriptCallback
    var pattern : String
    var files : [Path] = []
    
    init(callback: ScriptCallback, pattern: String) {
        self.callback = callback
        self.pattern = pattern
    }
    
    func validate() -> Bool {
        self.files = Path.glob(pattern)
        if self.files.count == 0 {
            self.callback.scriptUpdate(text: "no file(s) found that look like: \(self.pattern)")
            return false
        }
        return true
    }
    
    func run(logLines : inout [LogLine], runState _ : inout RunState) -> Bool {
        let sortedPaths = self.sortFilesByCreationDate()

        for file in sortedPaths {
            self.callback.scriptUpdate(text: "Reading file \(file.string)")

            do {
                let data = try String(contentsOfFile: file.string, encoding: .utf8)
                let ar = data.components(separatedBy: .newlines)
                for line in ar {
                    logLines.append( LogLine(text: line))
                }
                self.callback.scriptUpdate(text: "... read \(ar.count) lines")
            } catch {
                self.callback.scriptUpdate(text: "... error reading file: \(error)")
                return false
            }
        }
        return true
    }

    func sortFilesByCreationDate() -> [Path] {
        return self.files.sorted(by: compareCreationDate)
    }

    func compareCreationDate(x: Path, y:Path) -> Bool {
        let dX = getCreationDate(path: x)
        let dY = getCreationDate(path: y)
        return dX.compare(dY) == ComparisonResult.orderedAscending
    }

    func getCreationDate(path: Path) -> Date {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path.string) as NSDictionary
            return attrs.fileCreationDate() ?? Date()
        } catch {
            return Date()
        }
    }

}
