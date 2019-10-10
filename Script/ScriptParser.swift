import Foundation

/**
 Parses script text into an executable list of ScriptCommands.
 */
class ScriptParser {
    var callback : ScriptCallback
    
    init(callback : ScriptCallback) {
        self.callback = callback
    }
    
    static func getReferenceText() -> String {
        """
        *** COMMENTS ***
        # comment           -- ignore the contents of any line starting with #
        
        *** ADDING LOG LINES ***
        < filename          -- input log lines from (filename)
        demo                -- generate sample log lines programmatically
        
        *** FILTERING/HILIGHTING LOG LINES ***
        : color             -- hilight following matches with (color)
        = regex             -- hide all lines not matching regex
        + regex             -- unhide all lines matching regex
        - regex             -- hide all lines matching regex
        ~ regex             -- hilight regex without changing which lines are hidden
        ==                  -- hide all lines not already hilighted
        today               -- hide all lines that don't contain today's date
        
        *** REMOVING LOG LINES ***
        chop                -- remove all hidden lines
        clear               -- remove ALL lines

        *** ADJUSTING LOG LINES ***
        truncate N          -- truncate lines with > N characters

        *** ANALYSIS ***
        d N                 -- identify lines duplicated more than N times
        
        """
    }
    
    func parse(script : String) -> (Bool, [ScriptCommand]) {
        var commands : [ScriptCommand] = []
        
        let ar = script.split(separator: "\n")
        
        for line in ar {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !parseComment(line: trimmedLine, commands: &commands) &&
                !parseReadFile(line: trimmedLine, commands: &commands) &&
                !parseToday(line: trimmedLine, commands: &commands) &&
                !parseRequireHilight(line: trimmedLine, commands: &commands) &&
                !parseFilter(line: trimmedLine, commands: &commands) &&
                !parseColor(line: trimmedLine, commands: &commands) &&
                !parseDetectDuplicates(line: trimmedLine, commands: &commands) &&
                !parseChop(line: trimmedLine, commands: &commands) &&
                !parseClear(line: trimmedLine, commands: &commands) &&
                !parseDemo(line: trimmedLine, commands: &commands) &&
                !parseTruncate(line: trimmedLine, commands: &commands)
            {
                self.callback.scriptUpdate(text: "FAILED TO PARSE DIRECTIVE: \(line)")
                return (false, [])
            }
        }
        
        return (true, commands)
    }
    
    func parseComment(line: String, commands : inout [ScriptCommand]) -> Bool {
        line.starts(with: "#") || line=="";
    }
    
    func parseFilter(line: String, commands : inout [ScriptCommand]) -> Bool {
        if line=="" {
            return false
        }
        
        // TODO: just assuming here that everything after the directive is the regular
        // expression.  Would it be better to have a lexer that recognizes quotes strings
        // and then just have this be a regular 2-part command?
        let rest = String(line.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        

        if line.starts(with: "=") {
            commands.append(FilterCommand(callback: self.callback, pattern: rest, filterType: FilterCommand.FilterType.Required))
            return true
        }
        if line.starts(with: "-") {
            commands.append(FilterCommand(callback: self.callback, pattern: rest, filterType: FilterCommand.FilterType.Remove))
            return true
        }
        if line.starts(with: "+") {
            commands.append(FilterCommand(callback: self.callback, pattern: rest, filterType: FilterCommand.FilterType.Add))
            return true
        }
        if line.starts(with: "~") {
            commands.append(FilterCommand(callback: self.callback, pattern: rest, filterType: FilterCommand.FilterType.Highlight))
            return true
        }
        
        return false
        
    }
    
    func detectDirective(line : String, directive: String, expectedNumArgs: Int) -> [String]? {
        let ar = line.split(separator: " ")
        if( ar[0] != directive ) {
            return nil
        }
        
        if( ar.count != expectedNumArgs+1 ) {
            self.callback.scriptUpdate(text: "DIRECTIVE \(ar[0]) REQUIRES \(expectedNumArgs) ARGUMENT(S)")
            return nil
        }
        
        return ar.map( {String($0)} )
    }
    
    func parseDetectDuplicates(line: String, commands : inout [ScriptCommand]) -> Bool {
        
        if let ar = detectDirective(line: line, directive: "d", expectedNumArgs: 1) {
            let n = Int(ar[1]) ?? 100
            let cmd = DetectDuplicatesCommand(callback: self.callback, threshold: n)
            commands.append(cmd)
            return true
        }
        // TODO: an alternative verison with d- or something to do filtering as well as detection?
        
        return false
    }
    
    
    func parseReadFile(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let ar = detectDirective(line: line, directive: "<", expectedNumArgs: 1) {
            let cmd = ReadFileCommand(callback: self.callback, file: String(ar[1]))
            commands.append(cmd)
            return true
        }
        
        return false
    }
    
    func parseColor(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let ar = detectDirective(line: line, directive: ":", expectedNumArgs: 1) {
            let cmd = ColorCommand(callback: self.callback, text: String(ar[1]))
            commands.append(cmd)
            return true
        }
        
        return false
    }
    
    func parseChop(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let _ = detectDirective(line: line, directive: "chop", expectedNumArgs: 0) {
            let cmd = ChopCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }
        
        return false
    }

    func parseRequireHilight(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let _ = detectDirective(line: line, directive: "==", expectedNumArgs: 0) {
            let cmd = RequireHilightCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }

        return false
    }


    func parseDemo(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let _ = detectDirective(line: line, directive: "demo", expectedNumArgs: 0) {
            let cmd = DemoCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }
        
        return false
    }
    
    func parseClear(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let _ = detectDirective(line: line, directive: "clear", expectedNumArgs: 0) {
            let cmd = ClearCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }
        
        return false
    }

    func parseTruncate(line: String, commands : inout [ScriptCommand]) -> Bool {
        if let ar = detectDirective(line: line, directive: "truncate", expectedNumArgs: 1) {
            let cmd = TruncateCommand(callback: self.callback, maxLength: Int(ar[1])!)
            commands.append(cmd)
            return true
        }

        return false
    }

    func parseToday(line: String, commands : inout [ScriptCommand]) -> Bool {
          if let _ = detectDirective(line: line, directive: "today", expectedNumArgs: 0) {
              let cmd = TodayCommand(callback: self.callback)
              commands.append(cmd)
              return true
          }

          return false
      }
}
