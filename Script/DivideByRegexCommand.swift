import Foundation

/**
 This command adds section headers to the log whenever the specified regex is matched
 */
class DivideByRegexCommand: ScriptCommand {
    var callback: ScriptCallback
    var pattern: String
    var regex: NSRegularExpression?

    init(callback: ScriptCallback, pattern: String) {
        self.callback = callback
        self.pattern = pattern
    }

    func validate() -> Bool {
        do {
            // parse the regex for efficient use later
            try self.regex = NSRegularExpression(pattern: self.pattern, options: [])
            return true
        } catch {
            self.callback.scriptUpdate(text: "invalid regular expression: \(self.pattern)")
            return false
        }
    }

    func changesData() -> Bool {
        true
    }

    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        var numFound = 0
        for line in logLines {
            let results = regex!.matches(in: line.text,
                    range: NSRange(line.text.startIndex..., in: line.text))
            if (results.count > 0) {
                numFound += 1
                line.setBeginSection(color: runState.color)
            }
        }
        self.callback.scriptUpdate(text: "Found \(numFound) section boundaries where lines match regex \(self.pattern)")
        return true
    }

}
