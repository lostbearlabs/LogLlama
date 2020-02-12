import Foundation

/**
 Parses script text into an executable list of ScriptCommands.
 */
class ScriptParser {
    var callback : ScriptCallback

    var rest_recognizers : [(String, (String,  ScriptCallback) -> ScriptCommand)] = [
        ("<", { rest, callback in return ReadFileCommand(callback: callback, pattern: rest)}),
        ("=", { rest, callback in return FilterCommand(callback: callback, pattern: rest, filterType: FilterCommand.FilterType.Required)}),
        ("+", { rest, callback in return FilterCommand(callback: callback, pattern: rest, filterType: FilterCommand.FilterType.Add)}),
        ("-", { rest, callback in return FilterCommand(callback: callback, pattern: rest, filterType: FilterCommand.FilterType.Remove)}),
        ("~", { rest, callback in return FilterCommand(callback: callback, pattern: rest, filterType: FilterCommand.FilterType.Highlight)}),
        ("require", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.Required)}),
        ("exclude", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.Excluded)}),
        ("clearFilters", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.Clear)}),
        ("requireToday", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.RequireToday)}),
        ("sql", { rest, callback in return SqlCommand(callback: callback, sql: rest)}),
    ]

    var token_recognizers : [(String, Int, ([String], ScriptCallback) -> ScriptCommand)] = [
        ("demo", 0, { tokens, callback in return DemoCommand(callback: callback)}),
        (":", 1, { tokens, callback in return ColorCommand(callback: callback, text: tokens[1])}),
        ("==", 0, { tokens, callback in return RequireHilightCommand(callback: callback)}),
        ("today", 0, { tokens, callback in return TodayCommand(callback: callback)}),
        ("chop", 0, { tokens, callback in return ChopCommand(callback: callback)}),
        ("clear", 0, { tokens, callback in return ClearCommand(callback: callback)}),
        ("truncate", 1, { tokens, callback in return TruncateCommand(callback: callback, maxLength: Int(tokens[1]) ?? 256 )}),
        ("d", 1, { tokens, callback in return DetectDuplicatesCommand(callback: callback, threshold: Int(tokens[1]) ?? 20 )}),
        ("dateFormat", 1, { tokens, callback in return DateFormatCommand(callback: callback, text: tokens[1])}),
    ]
    
    init(callback : ScriptCallback) {
        self.callback = callback
    }
    
    static func getReferenceText() -> String {
        """
        *** COMMENTS ***
        # comment           -- ignore the contents of any line starting with #
        
        *** ADDING LOG LINES ***
        require regex            -- when loading lines, filter out any that don't match regex
        exclude regex            -- when loading lines, filter out any that do match regex
        requireToday             -- when loading lines, filter out any that don't contain the current date
        clearFilters             -- clear any line loading filters
        < file name/pattern -- load log lines from matching files in order created
        demo                -- generate sample log lines programmatically
        
        *** FILTERING/HILIGHTING LOG LINES ***
        : color             -- hilight following matches with (color)
        = regex             -- hide all lines not matching regex
        + regex             -- unhide all lines matching regex
        - regex             -- hide all lines matching regex
        ~ regex             -- hilight regex without changing which lines are hidden
        ==                  -- hide all lines not already hilighted
        today               -- hide all lines that don't contain today's date
        dateFormat          -- set the date format for subsequent "today" and "requireToday" lines

        *** REMOVING LOG LINES ***
        chop                -- remove all hidden lines
        clear               -- remove ALL lines

        *** ADJUSTING LOG LINES ***
        truncate N          -- truncate lines with > N characters

        *** ANALYSIS ***
        d N                 -- identify lines duplicated more than N times
        sql ...             -- run specified SQL command against extracted fields
        """
    }
    
    func parse(script : String) -> (Bool, [ScriptCommand]) {
        var commands : [ScriptCommand] = []
        
        let ar = script.split(separator: "\n")

        for line in ar {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // ignore comments
            if( trimmedLine.starts(with: "#") || trimmedLine=="" ) {
                continue;
            }

            // split lines into tokens
            let tokens = line.split(separator: " ").map( { String($0) } )
            var rest = ""
            if( tokens.count > 1 ) {
                let offset = tokens[0].count + 1
                if offset < trimmedLine.count {
                    let start = trimmedLine.index(trimmedLine.startIndex, offsetBy: offset)
                    rest = String(trimmedLine[start...])
                }
            }

            var cmd : ScriptCommand? = nil

            // any matching directives that take the rest of the line as their argument?
            for r in self.rest_recognizers {
                if tokens[0]==r.0 {
                    cmd = r.1(rest, self.callback)
                }
            }

            // any matching directives that take space-separated arguments?
            for r in self.token_recognizers {
                if tokens[0]==r.0 {
                    if r.1 == tokens.count-1 {
                        cmd = r.2(tokens, self.callback)
                    } else {
                        self.callback.scriptUpdate(text: "DIRECTIVE \(tokens[0]) REQUIRES \(r.1) ARGUMENT(S)")
                    }
                }
            }

            if cmd != nil {
                commands.append(cmd!)
            } else {
                self.callback.scriptUpdate(text: "FAILED TO PARSE DIRECTIVE: \(line)")
                return (false, [])
            }
        }
        
        return (true, commands)
    }

}
