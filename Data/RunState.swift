import Foundation
import AppKit

/**
 Records the current state of the script engine, e.g. what color is currently selected.
 */
class RunState {
    var color = NSColor.green
    var filterRequired : [NSRegularExpression] = []
    var filterExcluded : [NSRegularExpression] = []
    var dateFormat = "MM\\.dd\\.yy"
    var fieldDataSql : FieldDataSql?
    var limit = 0
    var replace : [String:String] = [:]
}

