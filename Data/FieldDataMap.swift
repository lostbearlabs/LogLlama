import Foundation

/// Consolidates data from named groups in log lines.
class FieldDataMap {

  /// A list of the field data from each line.
  var data: [[String: String]] = []

  /// A dictionary of fields.
  /// Key is the field name, forced to lower case.
  /// Value is whether a non-integer value was every seen for that field.
  var fields: [String: Bool] = [:]

  var TEXT: String = "text"

  init() {
    fields[TEXT] = false
  }

  func addData(line: LogLine) {
    // data we'll save for this line
    var lineFields: [String: String] = [:]

    // collect all the extracted fields
    for it in line.namedFieldValues {
      let key = it.key.lowercased()
      lineFields[key] = it.value
      self.noteFieldName(key: key, value: it.value)
    }

    // also save the raw text
    lineFields[TEXT] = line.text

    self.data.append(lineFields)
  }

  func noteFieldName(key: String, value: String) {
    let isInt = Int(value) != nil
    if self.fields[key] == nil || self.fields[key] == true {
      self.fields[key] = isInt
    } else {
      self.fields[key] = false
    }
  }

}
