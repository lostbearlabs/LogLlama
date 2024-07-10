import Foundation

/**
 Parses script text into an executable list of ScriptCommands.
 */
class ScriptParser {
    var callback : ScriptCallback

    // These are commands that take "the rest of the line" as their argument
    var rest_recognizers : [(String, (String,  ScriptCallback) -> ScriptCommand)] = [
        ("<", { rest, callback in return ReadFileCommand(callback: callback, pattern: rest)}),
        ("=", { rest, callback in return FilterLineCommand(callback: callback, pattern: rest, filterType: FilterLineCommand.FilterType.Required)}),
        ("+", { rest, callback in return FilterLineCommand(callback: callback, pattern: rest, filterType: FilterLineCommand.FilterType.Add)}),
        ("-", { rest, callback in return FilterLineCommand(callback: callback, pattern: rest, filterType: FilterLineCommand.FilterType.Remove)}),
        ("~", { rest, callback in return FilterLineCommand(callback: callback, pattern: rest, filterType: FilterLineCommand.FilterType.Highlight)}),
        ("require", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.Required)}),
        ("exclude", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.Excluded)}),
        ("clearFilters", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.Clear)}),
        ("requireToday", { rest, callback in return LoadFilterCommand(callback: callback, pattern: rest, loadFilterType: LoadFilterCommand.LoadFilterType.RequireToday)}),
        ("sql", { rest, callback in return SqlCommand(callback: callback, sql: rest)}),
        ("/r", { rest, callback in return DivideByRegexCommand(callback: callback, pattern: rest)}),
        ("/=", { rest, callback in return FilterSectionCommand(callback: callback, pattern: rest, filterType: FilterLineCommand.FilterType.Required)}),
        ("/-", { rest, callback in return FilterSectionCommand(callback: callback, pattern: rest, filterType: FilterLineCommand.FilterType.Remove)}),
        ("sort", {rest, callback in return SortByFieldsCommand(callback: callback, fieldsString: rest)}),
    ]

    // These are commands that take individual tokenized elements from the line as their argument(s)
    var token_recognizers : [(String, Int, ([String], ScriptCallback) -> ScriptCommand)] = [
        ("demo", 0, { tokens, callback in return DemoCommand(callback: callback)}),
        (":", 1, { tokens, callback in return ColorCommand(callback: callback, text: tokens[1])}),
        ("==", 0, { tokens, callback in return RequireHilightCommand(callback: callback)}),
        ("today", 0, { tokens, callback in return TodayCommand(callback: callback)}),
        ("chop", 0, { tokens, callback in return ChopCommand(callback: callback)}),
        ("clear", 0, { tokens, callback in return ClearCommand(callback: callback)}),
        ("truncate", 1, { tokens, callback in return TruncateCommand(callback: callback, maxLength: Int(tokens[1]) ?? 256 )}),
        ("limit", 1, { tokens, callback in return LimitCommand(callback: callback, limit: Int(tokens[1]) ?? 1000000 )}),
        ("d", 1, { tokens, callback in return DetectDuplicatesCommand(callback: callback, threshold: Int(tokens[1]) ?? 20 )}),
        ("dateFormat", 1, { tokens, callback in return DateFormatCommand(callback: callback, text: tokens[1])}),
        ("@", 2, {tokens, callback in return AddFieldCommand(callback: callback, fieldToAdd: tokens[1], fieldToMatch: tokens[2])}),
        ("/f", 1, {tokens, callback in return DivideByFieldCommand(callback: callback, field: tokens[1])}),
        ("replace", 2, {tokens, callback in return ReplaceCommand(callback: callback, oldText: tokens[1], newText: tokens[2])}),
        ("sleep", 1, { tokens, callback in return SleepCommand(callback: callback, seconds: Int(tokens[1]) ?? 10 )}),

    ]
    
    init(callback : ScriptCallback) {
        self.callback = callback
    }
    
    static func getReferenceText() -> String {
        """
        *** COMMENTS ***
        # comment           -- ignore the contents of any line starting with #
        
        *** ADDING LOG LINES ***
        require regex       -- when loading lines, filter out any that don't match regex
        exclude regex       -- when loading lines, filter out any that do match regex
        requireToday        -- when loading lines, filter out any that don't contain the current date
        clearFilters        -- clear any line loading filters
        < file name/pattern -- load log lines from matching files in order created
        demo                -- generate sample log lines programmatically
        limit N             -- truncate files with > N lines
        replace a b         -- when importing lines, replace any occurence of a with b
        sort field1 field2  -- sort lines according to field list, with text comparison as the last condition

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
        @ field1 field2     -- populate lines that have field2 but not field1 with the value from another line that has field1 and the same value of field2

        *** ANALYSIS ***
        d N                 -- identify lines duplicated more than N times
        sql ...             -- run specified SQL command against extracted fields

        *** SECTIONS ***
        /r regex            -- mark lines that match regex as section headers
        /f field            -- mark lines where the value of field changes as section headers
        /= regex            -- hide any sections that don't have a line matching regex
        /- regex            -- hide any sections that do have a line matching reges

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
