import SwiftHamcrest
import XCTest

@testable import LogLlama

class RegexWithGroupsTest: XCTestCase {

  override func setUp() {
  }

  override func tearDown() {
  }

  func test_invalidPattern_throws() {
    assertThrows(
      try {
        try RegexWithGroups(pattern: "\\(x)")
      }())
  }

  func test_pattern_hasMatch_success() throws {
    let pattern = "foo"
    let regex = try RegexWithGroups(pattern: pattern)
    let rc = regex.hasMatch(text: "a foo b")
    assertThat(rc, equalTo(true))
  }

  func test_pattern_hasMatch_failure() throws {
    let pattern = "foo"
    let regex = try RegexWithGroups(pattern: pattern)
    let rc = regex.hasMatch(text: "a bar b")
    assertThat(rc, equalTo(false))
  }

  func test_pattern_hasWholeMatch_success() throws {
    let pattern = "foo"
    let regex = try RegexWithGroups(pattern: pattern)
    let rc = regex.hasWholeMatch(text: "foo")
    assertThat(rc, equalTo(true))
  }

  func test_pattern_hasWholeMatch_failure() throws {
    let pattern = "foo"
    let regex = try RegexWithGroups(pattern: pattern)
    let rc = regex.hasWholeMatch(text: "foox")
    assertThat(rc, equalTo(false))
  }

  func test_captures_full() throws {
    let pattern = "a=(?<x>\\d+), b=(?<y>\\d+)"
    let regex = try RegexWithGroups(pattern: pattern)

    let captures = regex.captures(text: "a=123, b=456")
    assertThat(captures, hasCount(1))

    let capture1 = captures[0]
    assertThat(capture1, hasEntry("x", "123"))
    assertThat(capture1, hasEntry("y", "456"))
  }

  func test_captures_partial() throws {
    let pattern = "a=(?<x>\\d+), b=(?<y>\\d+)"
    let regex = try RegexWithGroups(pattern: pattern)
    let captures = regex.captures(text: "c=927, a=123, b=456, d=822")
    assertThat(captures, hasCount(1))

    let capture1 = captures[0]
    assertThat(capture1, hasEntry("x", "123"))
    assertThat(capture1, hasEntry("y", "456"))
  }

  func test_captures_multiple() throws {
    let pattern = "(?<x>\\w+)=(?<y>\\d+)"
    let regex = try RegexWithGroups(pattern: pattern)
    let captures = regex.captures(text: "a=2, b=3, c=4")
    assertThat(captures, hasCount(3))

    assertThat(captures[0], hasCount(2))
    assertThat(captures[0], hasEntry("x", "a"))
    assertThat(captures[0], hasEntry("y", "2"))

    assertThat(captures[1], hasCount(2))
    assertThat(captures[1], hasEntry("x", "b"))
    assertThat(captures[1], hasEntry("y", "3"))

    assertThat(captures[2], hasCount(2))
    assertThat(captures[2], hasEntry("x", "c"))
    assertThat(captures[2], hasEntry("y", "4"))
  }

  func test_captures_ignoresUnnamed() throws {
    let pattern = "a=(\\d+), b=(?<b>\\d+), c=(\\d+)"
    let regex = try RegexWithGroups(pattern: pattern)
    let captures = regex.captures(text: "a=123, b=456, c=789")
    assertThat(captures, hasCount(1))
    assertThat(captures[0], hasCount(1))
    assertThat(captures[0], hasEntry("b", "456"))
  }

  func test_groupNames_findsThem() throws {
    let pattern = "a (?<b>c+) d (?<e>f+) g"
    let regex = try RegexWithGroups(pattern: pattern)
    let names = regex.groupNames()
    assertThat(names, contains("b", "e"))
  }

  func test_ranges_findsThem() throws {
    let pattern = "\\d+"
    let regex = try RegexWithGroups(pattern: pattern)
    let text = "123abc456def78gh"
    let ranges = regex.ranges(text: text)

    let startIndex = text.startIndex
    assertThat(
      ranges,
      (contains(
        text.index(startIndex, offsetBy: 0)..<text.index(startIndex, offsetBy: 3),
        text.index(startIndex, offsetBy: 6)..<text.index(startIndex, offsetBy: 9),
        text.index(startIndex, offsetBy: 12)..<text.index(startIndex, offsetBy: 14)
      )))
  }

}
