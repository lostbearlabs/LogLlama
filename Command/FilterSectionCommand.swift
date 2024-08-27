import Foundation

/// This command displays or hides sections if any line in them matches the specified regex.
class FilterSectionCommand: ScriptCommand {
  var callback: ScriptCallback?
  var pattern: String = ""
  var regex: RegexWithGroups?
  var filterType: FilterType = FilterType.add
  var numHidden = 0
  var numVisible = 0

  required init() {
  }
  
  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }
  
  func validate() -> Bool {
    do {
      // parse the regex for efficient use later
      try self.regex = RegexWithGroups(pattern: self.pattern)
      return true
    } catch {
      log("invalid regular expression: \(self.pattern)")
      return false
    }
  }

  func getOp(line: ScriptLine) -> FilterType? {
    switch line.op() {
    case "/=":
      return FilterType.required
    case "/-":
      return FilterType.remove
    default:
      return nil
    }
  }
  
  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let filterType=getOp(line: line), let pattern=line.rest(), line.done(){
      self.pattern = pattern
      self.filterType = filterType
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


  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    log("Applying regular expression: \(self.pattern)")

    if let regex = self.regex {
      var numHidden = 0
      var numVisible = 0

      logLines.filterSection(
        regex: regex, numVisible: &numVisible, numHidden: &numHidden, filterType: filterType)

      log("... \(self.numHidden) section(s) hidden, \(self.numVisible) remain visible")

      return true

    } else {
      log("... regex not defined")
      return false
    }

  }

  func undoText() -> String {
    switch filterType {
    case .required:
      return "/="
    case .remove:
      return "/-"
    default:
      return "?"
    }
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .sections,
        op: "/=",
        args: "regex",
        description: "hide any sections that don't have a line matching regex"
      ),
      ScriptCommandDescription(
        category: .sections,
        op: "/-",
        args: "regex",
        description: "hide any sections that have a line matching regex"
      ),

    ]
  }

}
