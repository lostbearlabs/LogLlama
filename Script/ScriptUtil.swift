import Foundation

let numberFormatter : NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

func withCommas(_ num: Int) -> String {
    return numberFormatter.string(from: NSNumber(value: num)) ?? "?"
}
