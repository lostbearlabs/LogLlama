import Foundation

enum ScriptCommandCategory: String {
  case adding = "*** ADDING LOG LINES ***"
  case removing = "*** REMOVING LOG LINES ***"
  case adjusting = "*** ADJUSTING LOG LINES ***"
  case analysis = "*** ANALYSIS ***"
  case filter = "*** FILTERING/HILIGHTING LOG LINES ***"
  case sections = "*** SECTIONS ***"
  case misc = "*** MISC ***"
  
  static func < (lhs: ScriptCommandCategory, rhs: ScriptCommandCategory) -> Bool {
         return lhs.rawValue < rhs.rawValue
  }
}

struct ScriptCommandDescription {
  let category: ScriptCommandCategory
  let op: String
  let args: String
  let description: String
}
