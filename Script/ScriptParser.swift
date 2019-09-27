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

        *** REMOVING LOG LINES ***
        chop                -- remove all hidden lines
        clear               -- remove ALL lines 

        *** ANALYSIS ***
        d                   -- analyze lines for duplicates
        
        """
    }
    
    func parse(script : String) -> (Bool, [ScriptCommand]) {
        var commands : [ScriptCommand] = []
        
        let ar = script.split(separator: "\n")
        
        for line in ar {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !parseComment(line: trimmedLine, commands: &commands) &&
                !parseReadFile(line: trimmedLine, commands: &commands) &&
                !parseFilter(line: trimmedLine, commands: &commands) &&
                !parseColor(line: trimmedLine, commands: &commands) &&
                !parseDetectDuplicates(line: trimmedLine, commands: &commands) &&
                !parseChop(line: trimmedLine, commands: &commands) &&
                !parseClear(line: trimmedLine, commands: &commands) &&
                !parseDemo(line: trimmedLine, commands: &commands)
            {
                
                self.callback.scriptUpdate(text: "UNKNOWN DIRECTIVE: \(line)")
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
    
    func parseDetectDuplicates(line: String, commands : inout [ScriptCommand]) -> Bool {
        if line=="" {
            return false
        }
        
        let ar = line.split(separator: " ")
        if ar.count==2 {
            let n = Int(ar[1]) ?? 100
            if (ar[0] == "d") {
                let cmd = DetectDuplicatesCommand(callback: self.callback, threshold: n)
                commands.append(cmd)
                return true
            }
            // TODO: d- or something for filtering?
        }
        
        
        return false
        
    }
    
    
    func parseReadFile(line: String, commands : inout [ScriptCommand]) -> Bool {
        let ar = line.split(separator: " ")
        if ar.count==2 && ar[0]=="<" {
            let cmd = ReadFileCommand(callback: self.callback, file: String(ar[1]))
            commands.append(cmd)
            return true
        }
        
        return false
    }
    
    func parseColor(line: String, commands : inout [ScriptCommand]) -> Bool {
        let ar = line.split(separator: " ")
        if ar.count==2 && ar[0]==":" {
            let cmd = ColorCommand(callback: self.callback, text: String(ar[1]))
            commands.append(cmd)
            return true
        }
        
        return false
    }
    
    func parseChop(line: String, commands : inout [ScriptCommand]) -> Bool {
        let ar = line.split(separator: " ")
        if ar.count==1 && ar[0]=="chop" {
            let cmd = ChopCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }
        
        return false
    }
    
    func parseDemo(line: String, commands : inout [ScriptCommand]) -> Bool {
        let ar = line.split(separator: " ")
        if ar.count==1 && ar[0]=="demo" {
            let cmd = DemoCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }
        
        return false
    }

    func parseClear(line: String, commands : inout [ScriptCommand]) -> Bool {
        let ar = line.split(separator: " ")
        if ar.count==1 && ar[0]=="clear" {
            let cmd = ClearCommand(callback: self.callback)
            commands.append(cmd)
            return true
        }

        return false
    }

}
