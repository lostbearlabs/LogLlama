import Foundation

/// This command displays or hides sections if any line in them matches the specified regex.
class FilterSectionCommand: ScriptCommand {
  var callback: ScriptCallback
  var pattern: String
  var regex: RegexWithGroups?
  var filterType: FilterType
  var numHidden = 0
  var numVisible = 0

  init(callback: ScriptCallback, pattern: String, filterType: FilterType) {
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

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    self.callback.scriptUpdate(text: "Applying regular expression: \(self.pattern)")

    if let regex = self.regex {
      var numHidden = 0
      var numVisible = 0

      logLines.filterSection(
        regex: regex, numVisible: &numVisible, numHidden: &numHidden, filterType: filterType)

      self.callback.scriptUpdate(
        text: "... \(self.numHidden) section(s) hidden, \(self.numVisible) remain visible")

      return true

    } else {
      self.callback.scriptUpdate(
        text: "... regex not defined")
      return false
    }

  }

  func description() -> String {
    return "/="
  }

}
