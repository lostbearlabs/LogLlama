/// Provides access to the operator and arguments within a script line
class ScriptLine {
  private var remaining: String
  private var first: String?

  init(line: String) {
    let trimmedLine = line.trimmingCharacters(in: .whitespaces)

    if trimmedLine.first == "#" {
      self.remaining = ""
    } else {
      self.remaining = line
    }

    self.first = pop()
  }

  func op() -> String? {
    return first
  }

  // Return the next argument.
  func pop() -> String? {
    guard !remaining.isEmpty else {
      return nil
    }

    if let spaceIndex = remaining.firstIndex(of: " ") {
      let word = String(remaining[..<spaceIndex])
      remaining = String(remaining[remaining.index(after: spaceIndex)...])
      remaining = remaining.trimmingCharacters(in: .whitespaces)
      return word
    } else {
      let word = remaining
      remaining = ""
      return word
    }
  }

  func popInt() -> Int? {
    if let st = pop() {
      if let n = Int(st) {
        return n
      }
    }

    return nil
  }

  // Return the remainder of the line.
  func rest() -> String? {
    guard !remaining.isEmpty else {
      return nil
    }

    let restOfString = remaining
    remaining = ""
    return restOfString
  }

  func done() -> Bool {
    return remaining.isEmpty
  }

  func pop(regex: Regex<Substring>) -> String? {
    var found: String? = nil

    let matches = remaining.matches(of: regex)
    if let match = matches.first {
      let range = match.range
      if range.lowerBound == remaining.startIndex {
        found = String(remaining[range])
        remaining.removeSubrange(range)
        remaining = remaining.trimmingCharacters(in: .whitespaces)
      }
    }

    return found
  }

  func popDelimitedString() -> String? {
    guard let firstChar = remaining.first else {
      return nil  // Return nil if the string is empty
    }

    var index = remaining.startIndex
    var foundIndex: String.Index?
    var isEscaped = false
    var found = ""

    while index < remaining.endIndex {
      let currentChar = remaining[index]

      if isEscaped {
        isEscaped = false
        found.append(String(currentChar))
      } else if currentChar == "\\" {
        isEscaped = true
      } else if currentChar == firstChar && index != remaining.startIndex {
        foundIndex = index
        break
      } else if index != remaining.startIndex {
        found.append(String(currentChar))
      }

      // advance index safely
      remaining.formIndex(after: &index)
    }

    guard let endIndex = foundIndex else {
      return nil  // Return nil if no matching delimiter is found
    }

    let range = remaining.startIndex..<remaining.index(after: endIndex)
    remaining.removeSubrange(range)
    remaining = remaining.trimmingCharacters(in: .whitespaces)
    return found
  }

  func popDelimitedStringArray(numElements: Int) -> [String]? {
    guard let firstChar = remaining.first else {
      return nil  // Return nil if the string is empty
    }

    var index = remaining.startIndex
    var foundIndex: String.Index?
    var isEscaped = false
    var found = ""
    var result: [String] = []

    while index < remaining.endIndex {
      let currentChar = remaining[index]

      if isEscaped {
        isEscaped = false
        found.append(String(currentChar))
      } else if currentChar == "\\" {
        isEscaped = true
      } else if currentChar == firstChar && index != remaining.startIndex {
        // Accumulate the result so far
        result.append(found)
        found = ""

        // Break when we've accumulated enough
        if result.count == numElements {
          foundIndex = index
          break
        }

      } else if index != remaining.startIndex {
        found.append(String(currentChar))
      }

      // advance index safely
      remaining.formIndex(after: &index)
    }

    // remove all the stuff we took
    guard let endIndex = foundIndex else {
      return nil  // Return nil if no matching delimiter is found
    }
    let range = remaining.startIndex..<remaining.index(after: endIndex)
    remaining.removeSubrange(range)

    // remove any prefix whitespace
    remaining = remaining.trimmingCharacters(in: .whitespaces)

    return result
  }

}
