import SwiftHamcrest
import XCTest

@testable import LogLlama

class LogLineArrayTest: XCTestCase {
  override func setUp() {
  }

  override func tearDown() {
  }

  func test_chop_removesHiddenLines() {
    let ar = givenData(numLines: 5)
    ar[1].visible = false
    ar[3].visible = false

    ar.chop()

    assertThat(ar.count, equalTo(3))
    assertThat(ar[0].lineNumber, equalTo(1))
    assertThat(ar[1].lineNumber, equalTo(2))
    assertThat(ar[2].lineNumber, equalTo(3))
  }

  func test_clear_removesAllLines() {
    let ar = givenData(numLines: 5)

    ar.clear()

    assertThat(ar.count, equalTo(0))
  }

  func test_parseFields_findsExpectedValues() throws {
    let ar = givenData(numLines: 3)
    let regex = try RegexWithGroups(pattern: "(?<key>\\w+)=(?<value>\\d+)")

    ar.parseFields(regex: regex)

    assertThat(ar[0].namedFieldValues["line"], equalTo("0"))
    assertThat(ar[1].namedFieldValues["line"], equalTo("1"))
    assertThat(ar[2].namedFieldValues["line"], equalTo("2"))
  }

  func test_applyFilter_matches() throws {
    let ar = givenData(numLines: 3)
    let regex = try RegexWithGroups(pattern: "line=2,")

    let n = ar.applyFilter(regexFromFilter: regex, filterType: .required, color: NSColor.black)

    assertThat(n, equalTo(1))

    assertThat(ar[0].visible, equalTo(false))
    assertThat(ar[1].visible, equalTo(false))
    assertThat(ar[2].visible, equalTo(true))
  }

  func test_applyFilter_withLineRangeAddress_matches() throws {
    let ar = givenData(numLines: 10)
    let address = SedAddress(range: (6, 8))

    // Start with all hidden.
    for line in ar.lines {
      line.visible = false
    }

    // Unhide lines in range
    let n = ar.applyFilter(
      regexFromFilter: nil, filterType: .add, color: NSColor.black, address: address)

    assertThat(n, equalTo(3))

    for line in ar.lines {
      let expectedMatch = (line.lineNumber >= 6 && line.lineNumber <= 8)
      assertThat(line.visible, equalTo(expectedMatch))
    }
  }

  func test_applyFilter_withPatternAddress_matches() throws {
    let ar = givenData(numLines: 3)
    let address = SedAddress(regex: try RegexWithGroups(pattern: "line=2"))

    let n = ar.applyFilter(
      regexFromFilter: nil, filterType: .required, color: NSColor.black, address: address)

    assertThat(n, equalTo(1))

    assertThat(ar[0].visible, equalTo(false))
    assertThat(ar[1].visible, equalTo(false))
    assertThat(ar[2].visible, equalTo(true))
  }

  func test_applyFilter_findsFields() throws {
    let ar = givenData(numLines: 3)
    let regex = try RegexWithGroups(pattern: "line=(?<lineNum>\\d+)")

    let n = ar.applyFilter(regexFromFilter: regex, filterType: .required, color: NSColor.black)

    assertThat(n, equalTo(3))

    assertThat(ar[0].namedFieldValues["lineNum"], equalTo("0"))
    assertThat(ar[1].namedFieldValues["lineNum"], equalTo("1"))
    assertThat(ar[2].namedFieldValues["lineNum"], equalTo("2"))
  }

  func test_hideNotHilighted_happyPath() throws {
    let ar = givenData(numLines: 4)

    ar[0].visible = true
    ar[0].matched = true

    ar[1].visible = true
    ar[1].matched = false

    ar[2].visible = false
    ar[2].matched = true

    ar[3].visible = false
    ar[3].matched = false

    let n = ar.hideNotHilighted()

    assertThat(n, equalTo(1))
    assertThat(ar[1].visible, equalTo(false))
  }

  func test_divideByRegex_identifiesSectionHeaders() throws {
    let ar = givenData(numLines: 6)
    let regex = try RegexWithGroups(pattern: "mod3=1")
    let color = NSColor.purple

    let n = ar.divideByRegex(regex: regex, color: color)

    assertThat(n, equalTo(2))
    assertThat(ar[1].beginSection, equalTo(true))
    assertThat(ar[4].beginSection, equalTo(true))
  }

  func test_divideByField_identifiesSectionHeaders() throws {
    let ar = givenData(numLines: 6)
    let regex = try RegexWithGroups(pattern: "(?<key>\\w+)=(?<value>\\d+)")
    ar.parseFields(regex: regex)

    let n = ar.divideByField(field: "div3", color: NSColor.purple)

    assertThat(n, equalTo(2))
    assertThat(ar[0].beginSection, equalTo(true))
    assertThat(ar[3].beginSection, equalTo(true))
  }

  func test_addFieldCommand_happyPath() throws {
    let ar = givenData(numLines: 2)

    // line1 has ID but not name
    ar[0].namedFieldValues["serverId"] = "1"

    // line2 has both
    ar[1].namedFieldValues["serverId"] = "1"
    ar[1].namedFieldValues["serverName"] = "central"

    _ = ar.addField(fieldToAdd: "serverName", fieldToMatch: "serverId")

    // Now line1 has both too
    assertThat(ar[0].namedFieldValues["serverName"], equalTo("central"))
  }

  func test_filterSection_happyPath() throws {
    let ar = givenData(numLines: 12)
    ar[0].setBeginSection(color: NSColor.blue)
    ar[3].setBeginSection(color: NSColor.blue)
    ar[6].setBeginSection(color: NSColor.blue)
    ar[9].setBeginSection(color: NSColor.blue)

    // match line=1, but also line=10 and line=11
    let regex = try RegexWithGroups(pattern: "line=1")

    var numVisible = 0
    var numHidden = 0
    ar.filterSection(
      regex: regex, numVisible: &numVisible, numHidden: &numHidden, filterType: FilterType.required)

    assertThat(numVisible, equalTo(2))
    assertThat(numHidden, equalTo(2))

    for i in 0..<12 {
      if i < 3 || i >= 9 {
        assertThat(ar[i].visible, equalTo(true))
      } else {
        assertThat(ar[i].visible, equalTo(false))
      }

    }
  }

  func test_sortByFields_happyPath() {
    let ar = givenData(numLines: 3)
    ar[0].namedFieldValues["x"] = "ghi"
    ar[1].namedFieldValues["x"] = "def"
    ar[2].namedFieldValues["x"] = "abc"

    ar.sortByFields(fieldNames: ["x"])

    assertThat(ar[0].lineNumber, equalTo(2))
    assertThat(ar[1].lineNumber, equalTo(1))
    assertThat(ar[2].lineNumber, equalTo(0))
  }

  func test_replace_happyPath() throws {
    let ar = givenData(numLines: 1)
    ar[0].text = "abc def ghi jkl"
    ar[0].attributed = NSMutableAttributedString(string: ar[0].text)
    let regex = try RegexWithGroups(pattern: "def")

    let n = ar.replace(regex: regex, text: "xyz", global: true, address: nil)
    assertThat(n, equalTo(1))
    assertThat(ar[0].text, equalTo("abc xyz ghi jkl"))
    assertThat(ar[0].attributed.string, equalTo("abc xyz ghi jkl"))
  }

  func test_replace_honorsAddress() throws {
    let ar = givenData(numLines: 3)
    let regex = try RegexWithGroups(pattern: "\\w+=\\d+")
    let address = SedAddress(range: (1, 1))

    let n = ar.replace(regex: regex, text: "zzz", global: true, address: address)
    assertThat(n, equalTo(1))
    assertThat(ar[1].text, equalTo("zzz, zzz, zzz"))
    assertThat(ar[1].attributed.string, equalTo("zzz, zzz, zzz"))
  }

  func test_replace_notGlobal_replacesOne() throws {
    let ar = givenData(numLines: 1)
    ar[0].text = "abc abc abc"
    ar[0].attributed = NSMutableAttributedString(string: ar[0].text)
    let regex = try RegexWithGroups(pattern: "abc")

    let n = ar.replace(regex: regex, text: "xyz", global: false, address: nil)
    assertThat(n, equalTo(1))
    assertThat(ar[0].text, equalTo("xyz abc abc"))
    assertThat(ar[0].attributed.string, equalTo("xyz abc abc"))
  }

  func test_replace_global_replacesAll() throws {
    let ar = givenData(numLines: 1)
    ar[0].text = "abc abc abc"
    ar[0].attributed = NSMutableAttributedString(string: ar[0].text)

    let regex = try RegexWithGroups(pattern: "abc")

    let n = ar.replace(regex: regex, text: "xyz", global: true, address: nil)
    assertThat(n, equalTo(1))
    assertThat(ar[0].text, equalTo("xyz xyz xyz"))
    assertThat(ar[0].attributed.string, equalTo("xyz xyz xyz"))
  }

  func test_change_changesText() throws {
    let ar = givenData(numLines: 2)
    let address = SedAddress(range: (1, 1))
    let text = "banana"
    let n = ar.change(address: address, replacementText: text, color: NSColor.black)

    assertThat(n, equalTo(1))

    assertThat(ar[1].text, equalTo(text))
    assertThat(ar[1].attributed.string, equalTo(text))

    assertThat(ar[0].text, not(equalTo(text)))
  }

  func test_delete_removesLines() throws {
    let ar = givenData(numLines: 3)
    let address = SedAddress(range: (0, 1))
    let n = ar.delete(address: address)

    assertThat(n, equalTo(2))

    assertThat(ar.count, equalTo(1))
    assertThat(ar[0].text, containsString("line=2"))
    assertThat(ar[0].lineNumber, equalTo(1))
  }

  func test_insertBefore_addsLines() throws {
    let ar = givenData(numLines: 3)
    let address = SedAddress(range: (1, 1))
    let text = "banana"
    let n = ar.insertBefore(address: address, text: text, color: NSColor.black)

    assertThat(n, equalTo(1))

    assertThat(ar.count, equalTo(4))
    assertThat(ar[1].text, equalTo(text))
  }

  func test_insertAfter_addsLines() throws {
    let ar = givenData(numLines: 3)
    let address = SedAddress(range: (1, 1))
    let text = "banana"
    let n = ar.insertAfter(address: address, text: text, color: NSColor.black)

    assertThat(n, equalTo(1))

    assertThat(ar.count, equalTo(4))
    assertThat(ar[2].text, equalTo(text))
  }

  func givenData(numLines: Int) -> LogLineArray {
    let ar = LogLineArray()
    for i in 0..<numLines {
      let line = LogLine(text: "line=\(i), mod3=\(i%3), div3=\(i/3)", lineNumber: i)
      ar.append(line)
    }
    return ar
  }

}
