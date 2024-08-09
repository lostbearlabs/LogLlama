import Foundation

/**
 This command displays or hides sections if any line in them matches the specified regex.
 */
class FilterSectionCommand: ScriptCommand {
    var callback: ScriptCallback
    var pattern: String
    var regex: RegexWithGroups?
    var filterType: FilterLineCommand.FilterType
    var numHidden = 0
    var numVisible = 0
    
    init(callback: ScriptCallback, pattern: String, filterType: FilterLineCommand.FilterType) {
        self.callback = callback
        self.pattern = pattern
        self.filterType = filterType
    }
    
    func validate() -> Bool {
        do {
            // parse the regex for efficient use later
            try self.regex = RegexWithGroups(pattern: self.pattern)
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
        self.callback.scriptUpdate(text: "Applying regular expression: \(self.pattern)")
        
        var section: [LogLine] = []
        numHidden = 0
        numVisible = 0
        
        for line in logLines {
            if (!section.isEmpty && line.beginSection) {
                self.processSection(section: section);
                section.removeAll()
            }
            section.append(line)
        }
        self.processSection(section: section)
        
        self.callback.scriptUpdate(text: "... \(self.numHidden) section(s) hidden, \(self.numVisible) remain visible")
        return true
    }
    
    func processSection(section: [LogLine]) {
        if( !section.isEmpty) {
            if (self.keepVisible(section: section)) {
                if (section[0].visible) {
                    self.numVisible += 1
                }
            } else {
                for ln in section {
                    ln.visible = false
                }
                self.numHidden += 1
            }
        }
    }
    
    func keepVisible(section: [LogLine]) -> Bool {
        
        var match = false
        for line in section {
            if (regex!.hasMatch(text: line.text)) {
                match = true
            }
        }
        
        switch (self.filterType) {
        case .Required:
            return match
        case .Remove:
            return !match
        case .Add:
            return true
        case .Highlight:
            return true
        }
        
    }
    
    func description() -> String {
        return "/="
    }
    
    
}
