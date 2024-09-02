import Foundation

/// Parses script text into an executable list of ScriptCommands.
class ScriptParser {
  var callback: ScriptCallback?

  init(callback: ScriptCallback?) {
    self.callback = callback
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func parse(script: String) -> (Bool, [ScriptCommand]) {
    var commands: [ScriptCommand] = []
    let map = opToClass()

    let ar = script.split(separator: "\n")

    for line in ar {
      let scriptLine = ScriptLine(line: String(line))
      if let op = scriptLine.op() {
        if let cmdClass = map[op] {
          let cmd: ScriptCommand = cmdClass.init()
          if !cmd.setup(callback: callback!, line: scriptLine) {
            return (false, [])
          }
          commands.append(cmd)
        } else {
          log("FAILED TO PARSE DIRECTIVE: \(line)")
          return (false, [])
        }

      }
    }
    return (true, commands)
  }

  /// Swift does not allow us to reflect on classes, and using @objc imposes other restrictions like not using structs or
  /// inout.  So our parser depends on this canned list of command classes.
  var allSubclasses: [ScriptCommand.Type] = [
    AddFieldCommand.self,
    ChopCommand.self,
    ClearCommand.self,
    ColorCommand.self,
    DateFormatCommand.self,
    DemoCommand.self,
    DetectDuplicatesCommand.self,
    DivideByFieldCommand.self,
    DivideByRegexCommand.self,
    FilterLineCommand.self,
    FilterSectionCommand.self,
    LimitCommand.self,
    LoadFilterCommand.self,
    ParseFieldsCommand.self,
    ReadFileCommand.self,
    ReplaceCommand.self,
    RequireHilightCommand.self,
    SedCommand.self,
    SortByFieldsCommand.self,
    SqlCommand.self,
    TruncateCommand.self,
    SleepCommand.self,
  ]

  func opToClass() -> [String: ScriptCommand.Type] {

    return Dictionary(
      uniqueKeysWithValues:
        allSubclasses.flatMap { commandType in
          commandType.description.map { description in
            (description.op, commandType)
          }
        })
  }

  func getReferenceText() -> String {
    var lines: [String] = []
    lines.append("")
    lines.append("*** COMMENTS ***")
    lines.append(fmt("#", "comment", "ignore the contents of any line starting with #"))

    let descriptions: [ScriptCommandDescription] = allSubclasses.flatMap { cls in
      cls.description
    }

    let sorted: [ScriptCommandDescription] = descriptions.sorted {
      if $0.category == $1.category {
        return $0.op < $1.op
      } else {
        return $0.category < $1.category
      }
    }

    var category: ScriptCommandCategory? = nil
    for description in sorted {
      if category == nil || description.category != category {
        lines.append("")
        lines.append(description.category.rawValue)
        category = description.category
      }

      lines.append(fmt(description.op, description.args, description.description))
    }

    return lines.joined(separator: "\n")
  }

  private func fmt(_ op: String, _ args: String, _ description: String) -> String {
    let x = op + " " + args
    return rightPad(x, 22)
      + " --"
      + description
  }

  private func rightPad(_ st: String, _ n: Int) -> String {
    return st.padding(toLength: max(st.count, n), withPad: " ", startingAt: 0)
  }
}
