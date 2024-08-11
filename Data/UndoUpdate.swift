import Foundation

class UndoUpdate {
  var enabled: Bool
  var op: String?

  init(enabled: Bool, op: String?) {
    self.enabled = enabled
    self.op = op
  }
}
