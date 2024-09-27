import Foundation

enum SedCommandType: String {
  case hide = "-"
  case unhide = "+"
  case hilight = "~"
  case replace = "s"
  case change = "c"
  case delete = "d"
  case insert = "i"
  case append = "a"
}
