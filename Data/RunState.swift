import AppKit
import Foundation

/// Records the current state of the script engine, e.g. what color is currently selected.
class RunState {
  var color = NSColor.green
  var filterRequired: [RegexWithGroups] = []
  var filterExcluded: [RegexWithGroups] = []
  var dateFormat = "MM\\.dd\\.yy"
  var fieldDataSql: FieldDataSql?
  var limit = 0
  var replace: [String: String] = [:]

  func clone() -> RunState {
    let copy = RunState()
    copy.color = self.color
    copy.filterRequired = self.filterRequired
    copy.filterExcluded = self.filterExcluded
    copy.dateFormat = self.dateFormat
    copy.fieldDataSql = self.fieldDataSql
    copy.limit = self.limit
    copy.replace = self.replace
    return copy
  }
}
