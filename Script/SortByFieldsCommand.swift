/**
 This command re-sorts the log lines in order of the field(s) specified.

 If all fields match (or none are specified) then it defaults to sorting by the original line numbers.
 (TODO: this breaks down if there are lines from multiple files; maybe also include date or file name?)
 */
class SortByFieldsCommand : ScriptCommand {
    var callback : ScriptCallback
    var fields : [String]

    init(callback: ScriptCallback, fieldsString:String ) {
        self.callback = callback
        self.fields = fieldsString.split(separator: " ").map( { String($0) } )
    }

    func validate() -> Bool {
        true
    }

    func changesData() -> Bool {
        true
    }

    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        logLines.sort(by: {
            let line1 = $0
            let line2 = $1

            for field in self.fields {
                let val1 = $0.namedFieldValues[field]
                let val2 = $1.namedFieldValues[field]
                if val1 != val2 {
                    if val1 == nil {
                        if val2 != nil {
                            // only val2 is set;  line2 comes first
                            return false
                        }
                    } else {
                        if val2==nil {
                            // only val1 is set;  line1 comes first
                            return true
                        } else {
                            // val1 and val2 are set; compare them
                            return val1! < val2!
                        }
                    }
                }
            }

            // as a last resort, compare the line numbers of the lines
            return line1.lineNumber < line2.lineNumber
        })
        self.callback.scriptUpdate(text: "Sorted \(logLines.count) log lines")
        return true
    }

    func description() -> String {
        return "sort"
    }

}
