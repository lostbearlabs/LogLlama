import AppKit
import Foundation

/// Creates or clears filters to apply when loading lines
class LoadFilterCommand: ScriptCommand {
  
  enum LoadFilterType {
    case Required
    case Excluded
    case Clear
    case RequireToday
  }
  
  var callback: ScriptCallback?
  var loadFilterType: LoadFilterType = LoadFilterType.Clear
  var pattern: String = ""
  var regex: RegexWithGroups?
  
  required init() {
  }
  
  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }
    
  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let op = getOp(line: line) {
      self.loadFilterType = op
      if( op == LoadFilterType.Clear || op == LoadFilterType.RequireToday ) {
        if line.done() {
          return true
        } else {
          log("expected 0 arguments")
          return false
        }
      } else {
        if let pattern=line.rest(), line.done(){
          self.pattern = pattern
          do {
            // parse the regex for efficient use later
            try regex = RegexWithGroups(pattern: pattern)
            return true
          } catch {
            log("invalid regular expression: \(pattern)")
            return false
          }
        } else {
          log("expected 1 argument, pattern")
          return false
        }
      }
    } else {
      log("unexpected op")
      return false
    }
  }
  
  func changesData() -> Bool {
    false
  }
  
  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    switch self.loadFilterType {
      
    case .Required:
      runState.filterRequired.append(self.regex!)
      log("Added filter: Lines loaded must match: \(self.pattern)")
      return true
    case .RequireToday:
      // We have to set this up now, not at validation time, so it gets the most recent dateFormat value
      return self.setupToday(runState: runState)
    case .Excluded:
      log("Added filter: Lines loaded must not match: \(self.pattern)")
      runState.filterExcluded.append(self.regex!)
      return true
    case .Clear:
      log("Cleared filters on lines loaded")
      runState.filterRequired.removeAll()
      runState.filterExcluded.removeAll()
      return true
    }
    
  }
  
  func setupToday(runState: RunState) -> Bool {
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = runState.dateFormat
    let pattern = formatter.string(from: now)
    self.pattern = pattern
    
    do {
      try self.regex = RegexWithGroups(pattern: self.pattern)
      runState.filterRequired.append(self.regex!)
      log("Added filter: Lines loaded must match: \(self.pattern)")
      return true
    } catch {
      log("invalid regular expression: \(self.pattern)")
      return false
    }
  }
  
  func description() -> String {
    switch loadFilterType {
    case .Required:
      return "require"
    case .Excluded:
      return "exclude"
    case .Clear:
      return "clearFilters"
    case .RequireToday:
      return "RequireToday"
    }
  }
  
  func getOp(line: ScriptLine) -> LoadFilterType? {
    switch line.op() {
    case "require":
      return .Required
    case "exclude":
      return .Excluded
    case "clearFilters":
      return .Clear
    case "requireToday":
      return .RequireToday
    default:
      return nil
    }
  }
  
  
  
  func undoText() -> String {
    return SleepCommand.description[0].op
  }
  
  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .adding,
        op: "require",
        args: "regex",
        description: "when loading lines, filter out any that do not match regex"
      ),
      ScriptCommandDescription(
        category: .adding,
        op: "exclude",
        args: "regex",
        description: "when loading lines, filter out any that do match regex"
      ),
      ScriptCommandDescription(
        category: .adding,
        op: "requireToday",
        args: "",
        description: "when loading lines, filter out any that don't contain the current date"
      ),
      ScriptCommandDescription(
        category: .adding,
        op: "clearFilters",
        args: "",
        description: "clear any line loading filters"
      ),
      
    ]
  }
  
}
