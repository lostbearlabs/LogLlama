import Foundation

class ScriptParser {
    var callback : ScriptCallback
    
    init(callback : ScriptCallback) {
        self.callback = callback
    }
    
    func parse(script : String) -> (Bool, [ScriptCommand]) {
        var commands : [ScriptCommand] = []
        
        let ar = script.split(separator: "\n")
        
        for line in ar {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if !parseComment(line: trimmedLine, commands: &commands) &&
                !parseReadFile(line: trimmedLine, commands: &commands) &&
                !parseFilter(line: trimmedLine, commands: &commands)
            {
             
                self.callback.scriptUpdate(text: "UNKNOWN DIRECTIVE: \(line)")
                return (false, [])
            }
        }

        return (true, commands)
    }
    
    func parseComment(line: String, commands : inout [ScriptCommand]) -> Bool {
        return line.starts(with: "#") || line=="";
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
        if line.starts(with: "+") {
            commands.append(FilterCommand(callback: self.callback, pattern: rest, filterType: FilterCommand.FilterType.Highlight))
            return true
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

    
}
