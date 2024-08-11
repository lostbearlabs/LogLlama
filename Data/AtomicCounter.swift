import Foundation

final class AtomicCounter {
  private let lock = NSLock()
  private var value = 0

  func increment() {
    lock.lock()
    value += 1
    lock.unlock()
  }

  func get() -> Int {
    return value
  }
}
