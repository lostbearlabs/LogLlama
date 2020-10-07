/**
 This command re-sorts the log lines in order of the field(s) specified.
 */
class SortByFieldsCommand : ScriptCommand {
    var callback : ScriptCallback
    var fields : [String]

    // TODO: allow multiple fields
    init(callback: ScriptCallback, fields:[String] ) {
        self.callback = callback
        self.fields = fields
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

            // as a last resort, compare the text of the lines
            return line1.text < line2.text
        })
        self.callback.scriptUpdate(text: "Sorted \(logLines.count) log lines")
        return true
    }

}
