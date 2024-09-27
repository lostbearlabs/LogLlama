import Foundation

class SedCommand: ScriptCommand {

  var callback: ScriptCallback?
  var address: SedAddress?
  var action: SedCommandType?

  var replacePattern: RegexWithGroups?
  var replaceText: String?
  var replaceGlobal: Bool = false
  var newText: String?

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {
    return true
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback

    // Parse the address, which can be a line number, a pair of line numbers, or a delimited regex.
    if let nums = line.pop(regex: /\d+,\d+/) {
      let ar = nums.split(separator: ",")
      let a = Int(ar[0])!
      let b = Int(ar[1])!
      self.address = SedAddress(range: (a, b))
    } else if let num = line.pop(regex: /\d+/) {
      let a = Int(num)!
      self.address = SedAddress(range: (a, a))
    } else if let pattern = line.popDelimitedString() {
      do {
        var regex: RegexWithGroups
        try regex = RegexWithGroups(pattern: pattern)
        self.address = SedAddress(regex: regex)
      } catch {
        log("invalid regular expression: \(pattern)")
        return false
      }
    } else {
      self.address = SedAddress()
    }

    // Parse the op.
    if let op = line.pop(regex: /./) {
      if let action = SedCommandType(rawValue: op) {
        self.action = action
      } else {
        log("unknown sed operation \(op)")
        return false
      }
    } else {
      log("expected sed operation")
      return false
    }

    if action == .replace {
      if !parseReplaceArgs(line: line) {
        return false
      }
    }

    if action == .append || action == .insert || action == .change {
      if !parseNewText(line: line) {
        return false
      }
    }

    return true
  }

  func parseNewText(line: ScriptLine) -> Bool {
    newText = line.rest()
    if newText == nil || newText!.isEmpty {
      log("text required")
      return false
    }
    return true
  }

  func parseReplaceArgs(line: ScriptLine) -> Bool {
    if let args = line.popDelimitedStringArray(numElements: 2) {

      do {
        try self.replacePattern = RegexWithGroups(pattern: args[0])
      } catch {
        log("invalid regular expression: \(args[0])")
        return false
      }

      self.replaceText = args[1]

    } else {
      log("replace requires 2 delimited arguments /regex/text/")
      return false
    }

    if let rest = line.rest() {
      if rest.contains(/g/) {
        self.replaceGlobal = true
      }
    }

    return true
  }

  func changesData() -> Bool {
    true
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    var n = 0
    switch self.action! {
    case .hide:
      log("hiding lines that match address")
      n = logLines.applyFilter(
        regexFromFilter: nil, filterType: .remove, color: runState.color, address: address)
    case .hilight:
      log("hilighting lines that match address")
      n = logLines.applyFilter(
        regexFromFilter: nil, filterType: .highlight, color: runState.color, address: address)
    case .unhide:
      log("unhiding lines that match address")
      n = logLines.applyFilter(
        regexFromFilter: nil, filterType: .add, color: runState.color, address: address)
    case .replace:
      log("doing replace in lines that match address")
      n = logLines.replace(
        regex: replacePattern!, text: replaceText!, global: replaceGlobal, address: address)
    case .change:
      n = logLines.change(address: address, replacementText: newText!, color: runState.color)
    case .append:
      n = logLines.insertAfter(address: address, text: newText!, color: runState.color)
    case .insert:
      n = logLines.insertBefore(address: address, text: newText!, color: runState.color)
    case .delete:
      n = logLines.delete(address: address)
    }
    log("updated \(n) lines")
    return true
  }

  func undoText() -> String {
    return "\(LimitCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .misc,
        op: "sed",
        args: "COMMAND",
        description: "run sed command"
      )
    ]
  }

}
