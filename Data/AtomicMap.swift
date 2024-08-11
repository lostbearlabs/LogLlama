import Foundation

final class AtomicMap {
  private let lock = NSLock()
  private var map = [String: String]()

  func set(value: String, forKey: String) {
    lock.lock()
    defer { lock.unlock() }

    map[forKey] = value
  }

  func get(_ key: String) -> String? {
    lock.lock()
    defer { lock.unlock() }

    return map[key]
  }
}
