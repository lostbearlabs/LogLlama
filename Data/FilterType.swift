import Foundation

enum FilterType {
  case required
  case add
  case remove
  case highlight
  case today
}

let filter: FilterType = .remove
