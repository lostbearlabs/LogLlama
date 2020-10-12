import Foundation
import PathKit

/**
 Inputs log lines one or more log files as specified by glob pattern.
 */
class ReadFileCommand : ScriptCommand {
    var callback : ScriptCallback
    var pattern : String
    var files : [Path] = []
    var fieldNames = Set<String>()
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
        self.files = Path.glob(pattern)
        if self.files.count == 0 {
            self.callback.scriptUpdate(text: "no file(s) found that look like: \(self.pattern)")
            return false
        }
        return true
    }

    func changesData() -> Bool {
        true
    }

    
    func run(logLines : inout [LogLine], runState : inout RunState) -> Bool {
        let sortedPaths = self.sortFilesByCreationDate()

        for file in sortedPaths {
            self.callback.scriptUpdate(text: "Reading file \(file.string)")

            do {
                let data = try String(contentsOfFile: file.string, encoding: .utf8)
                let ar = data.components(separatedBy: .newlines)
                self.callback.scriptUpdate(text: "... processing \(ar.count) lines")

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
                        self.findNameValueFields(logLine: logLine)
                        numIncluded += 1
                    } else {
                        numExcluded += 1
                    }
                    numRead += 1
                    if( runState.limit>0 && numRead >= runState.limit) {
                        self.callback.scriptUpdate(text: "... reached file limit of  \(runState.limit) lines")
                        break
                    }
                    if( numRead%10000 == 0) {
                        self.callback.scriptUpdate(text: "... \(numRead)")
                    }
                }
                self.callback.scriptUpdate(text: "... read \(ar.count) lines, kept \(numIncluded), discarded \(numExcluded)")
            } catch {
                self.callback.scriptUpdate(text: "... error reading file: \(error)")
                return false
            }
        }
        self.callback.scriptUpdate(text: "... field names: \(self.fieldNames.sorted())")
        return true
    }

    func findNameValueFields(logLine:LogLine) {
        if( self.nameValueRegex != nil ) {
            let text = logLine.text
            let matches : [NSTextCheckingResult] = self.nameValueRegex!.matches(in: text, options: [], range: NSMakeRange(0, text.count))
            for match in matches {
                let nameRange = Range(match.range(at: 1), in: text)!
                let name = String(text[nameRange])

                let valRange = Range(match.range(at: 2), in: text)!
                let val = String(text[valRange])

                logLine.namedFieldValues[name] = val
                self.fieldNames.insert(name)
            }
        }
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
