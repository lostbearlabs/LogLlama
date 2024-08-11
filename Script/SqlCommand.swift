import Foundation

/// This command lets you analyze the tags from all (visible) lines by putting them into an in-memory database and then running
/// arbitrary SQL against them.
class SqlCommand: ScriptCommand {
  var callback: ScriptCallback
  var sql: String

  init(callback: ScriptCallback, sql: String) {
    self.callback = callback
    self.sql = sql
  }

  func validate() -> Bool {
    true
  }

  func changesData() -> Bool {
    false
  }

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    self.callback.scriptUpdate(text: "Running SQL")
    self.callback.scriptUpdate(text: "... \(self.sql)")

    if runState.fieldDataSql == nil {
      // consolidate named fields from lines
      let fieldMap = FieldDataMap()
      for line in logLines {
        if line.visible {
          fieldMap.addData(line: line)
        }
      }
      self.callback.scriptUpdate(text: "... consolidated data from log lines")

      do {
        // convert to SQL
        self.callback.scriptUpdate(text: "... adding data to SQL")
        runState.fieldDataSql = try FieldDataSql(data: fieldMap)
        self.callback.scriptUpdate(text: "... done added data to SQL")
      } catch {
        self.callback.scriptUpdate(text: "SQL ERROR: \(error).")
        return false
      }
    } else {
      self.callback.scriptUpdate(text: "... found current data in SQL")
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
        self.callback.scriptUpdate(text: "... | \(ar)")
      }
    } catch {
      self.callback.scriptUpdate(text: "SQL ERROR: \(error).")
    }

    return true
  }

  func description() -> String {
    return "sql"
  }

}
