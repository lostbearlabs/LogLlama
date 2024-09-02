import Foundation

class SedCommand: ScriptCommand {

  var callback: ScriptCallback?
  var address: SedAddress?
  var action: SedCommandType?

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
    } else if let pattern = line.popRegex() {
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

    // NOTE: some sed commands may have other parameters;  parse those here

    return true
  }

  func changesData() -> Bool {
    false
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
        category: .adding,
        op: "sed",
        args: "COMMAND",
        description: "run sed command"
      )
    ]
  }

}
