import Foundation

/// Sent from the AppDelegate and processed by all the view controllers.
class FontSizeUpdate {
  var size: Int

  init(size: Int) {
    self.size = size
  }
}
