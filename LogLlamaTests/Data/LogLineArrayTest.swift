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
    assertThat(ar[0].lineNumber, equalTo(0))
    assertThat(ar[1].lineNumber, equalTo(2))
    assertThat(ar[2].lineNumber, equalTo(4))
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

    let n = ar.applyFilter(regex: regex, filterType: .required, color: NSColor.black)

    assertThat(n, equalTo(1))

    assertThat(ar[0].visible, equalTo(false))
    assertThat(ar[1].visible, equalTo(false))
    assertThat(ar[2].visible, equalTo(true))
  }

  func test_applyFilter_findsFields() throws {
    let ar = givenData(numLines: 3)
    let regex = try RegexWithGroups(pattern: "line=(?<lineNum>\\d+)")

    let n = ar.applyFilter(regex: regex, filterType: .required, color: NSColor.black)

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

  func givenData(numLines: Int) -> LogLineArray {
    let ar = LogLineArray()
    for i in 0..<numLines {
      let line = LogLine(text: "line=\(i), mod3=\(i%3), div3=\(i/3)", lineNumber: i)
      ar.append(line)
    }
    return ar
  }

}