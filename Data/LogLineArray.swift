import Foundation

/// Encapsulates a list of LogLine objects, such as we display on the screen or keep in our undo buffer.
///
/// For ease of testing, logic for various commands that update the lines is also implemented on this class instead of
/// in the individual command classes.
class LogLineArray: Sequence {
  var lines: [LogLine] = []

  subscript(index: Int) -> LogLine {
    get {
      return lines[index]
    }
  }

  func makeIterator() -> IndexingIterator<[LogLine]> {
    return lines.makeIterator()
  }

  func append(_ line: LogLine) {
    lines.append(line)
  }

  var count: Int {
    return lines.count
  }

  func clear() {
    lines.removeAll()
  }

  func clone() -> LogLineArray {
    let other = LogLineArray()
    for line in lines {
      other.append(line.clone())
    }
    return other
  }

  /**
    Implementation for ChopCommand.
     */
  func chop() {
    lines.removeAll(where: { !$0.visible })
  }

}
