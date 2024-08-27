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
}
