import Foundation

/// This command lets you analyze the tags from all (visible) lines by putting them into an in-memory database and then running
/// arbitrary SQL against them.
class SqlCommand: ScriptCommand {
  var callback: ScriptCallback?
  var sql: String = ""

  required init() {
  }

  func log(_ st: String) {
    self.callback!.scriptUpdate(text: st)
  }

  func validate() -> Bool {
    true
  }

  func setup(callback: ScriptCallback, line: ScriptLine) -> Bool {
    self.callback = callback
    if let sql=line.rest(), line.done(){
      self.sql = sql
      return true
    } else {
      log("expected 1 argument, sql statement")
      return false
    }
  }

  
  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    log("Running SQL")
    log("... \(self.sql)")

    if runState.fieldDataSql == nil {
      // consolidate named fields from lines
      let fieldMap = FieldDataMap()
      for line in logLines {
        if line.visible {
          fieldMap.addData(line: line)
        }
      }
      log("... consolidated data from log lines")

      do {
        // convert to SQL
        log("... adding data to SQL")
        runState.fieldDataSql = try FieldDataSql(data: fieldMap)
        log("... done added data to SQL")
      } catch {
        log("SQL ERROR: \(error).")
        return false
      }
    } else {
      log("... found current data in SQL")
    }

    do {
      // perform query
      for row in try runState.fieldDataSql!.db.prepare(self.sql) {
        var ar: [Any] = []
        for i in 0...row.count - 1 {
          if let val = row[i] {
            ar.append(val)
          } else {
            ar.append("null")
          }
        }
        log("... | \(ar)")
      }
    } catch {
      log("SQL ERROR: \(error).")
    }

    return true
  }

  func undoText() -> String {
    return "\(SqlCommand.description[0].op)"
  }

  static var description: [ScriptCommandDescription] {
    return [
      ScriptCommandDescription(
        category: .analysis,
        op: "sql",
        args: "...",
        description: "run specified SQL command against extracted fields"
      )
    ]
  }

}
