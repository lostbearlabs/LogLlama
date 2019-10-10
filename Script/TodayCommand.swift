import Foundation

/**
 Applies an = filter with today's date
 */
class TodayCommand : FilterCommand {
    init(callback: ScriptCallback) {
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "MM\\.dd\\.yy"

        let pattern = formatter.string(from: now)

        super.init(callback: callback, pattern: pattern, filterType: FilterType.Required)
    }
}
