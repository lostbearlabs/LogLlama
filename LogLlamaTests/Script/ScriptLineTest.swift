import Foundation
import SwiftHamcrest
import XCTest

@testable import LogLlama

class ScriptLineTest: XCTestCase {

  override func setUp() {
  }

  override func tearDown() {
  }

  func test_pop_getsArgsThenNil() {
    let line = ScriptLine(line: "abc def ghi jkl")
    assertThat(line.op(), equalTo("abc"))
    assertThat(line.pop(), equalTo("def"))
    assertThat(line.pop(), equalTo("ghi"))
    assertThat(line.pop(), equalTo("jkl"))
    assertThat(line.pop(), equalTo(nil))
  }

  func test_rest_getsRestThenNil() {
    let line = ScriptLine(line: "abc def ghi jkl")
    assertThat(line.op(), equalTo("abc"))
    assertThat(line.pop(), equalTo("def"))
    assertThat(line.rest(), equalTo("ghi jkl"))
    assertThat(line.rest(), equalTo(nil))
    assertThat(line.pop(), equalTo(nil))
  }

  func test_emptyLine_returnsNill() {
    let line = ScriptLine(line: "")
    assertThat(line.rest(), equalTo(nil))
    assertThat(line.pop(), equalTo(nil))
  }

  func test_commentLine_returnsNill() {
    let line = ScriptLine(line: "# this is a comment")
    assertThat(line.rest(), equalTo(nil))
    assertThat(line.pop(), equalTo(nil))
  }

  func test_commentLineIndented_returnsNill() {
    let line = ScriptLine(line: "      # this is a comment")
    assertThat(line.rest(), equalTo(nil))
    assertThat(line.pop(), equalTo(nil))
  }

  func test_pop_withRegexHhappyPath() {
    let line = ScriptLine(line: "sed twas brillig and the slivey toves")
    let regex = /twas/
    let found = line.pop(regex: regex)
    assertThat(found, equalTo("twas"))
    assertThat(line.rest(), equalTo("brillig and the slivey toves"))
  }

  func test_pop_withRegexNoMatch() {
    let line = ScriptLine(line: "sed twas brillig and the slivey toves")
    let regex = /xyz/
    let found = line.pop(regex: regex)
    assertThat(found, equalTo(nil))
    assertThat(line.rest(), equalTo("twas brillig and the slivey toves"))
  }

  func test_pop_withRegexMatchButNotAtFround() {
    let line = ScriptLine(line: "sed twas brillig and the slivey toves")
    let regex = /brillig/
    let found = line.pop(regex: regex)
    assertThat(found, equalTo(nil))
    assertThat(line.rest(), equalTo("twas brillig and the slivey toves"))
  }

  func test_pop_withLineRegex_happyPath() {
    let line = ScriptLine(line: "sed 1 +")
    let regex = /\d+/
    let found = line.pop(regex: regex)
    assertThat(found, equalTo("1"))
    assertThat(line.rest(), equalTo("+"))
  }

  func test_pop_withRangeRegex_happyPath() {
    let line = ScriptLine(line: "sed 12,13 +")
    let regex = /\d+,\d+/
    let found = line.pop(regex: regex)
    assertThat(found, equalTo("12,13"))
    assertThat(line.rest(), equalTo("+"))
  }

  func test_pop_withOperatorRegex_happyPath() {
    let line = ScriptLine(line: "sed +")
    let regex = /./
    let found = line.pop(regex: regex)
    assertThat(found, equalTo("+"))
    assertThat(line.done(), equalTo(true))
  }

  func test_popDelimitedString_happyPath() {
    let line = ScriptLine(line: "sed /foo\\/bar/ +")
    let found = line.popDelimitedString()
    assertThat(found, equalTo("foo/bar"))
    assertThat(line.rest(), equalTo("+"))
  }

  func test_popDelimitedString_happyPathAlternateDelimiter() {
    let line = ScriptLine(line: "sed |foo\\/bar| +")
    let found = line.popDelimitedString()
    assertThat(found, equalTo("foo/bar"))
    assertThat(line.rest(), equalTo("+"))
  }

  func test_popDelimitedString_escapedBackslash() {
    let line = ScriptLine(line: "sed /a\\\\b/")
    let found = line.popDelimitedString()
    assertThat(found, equalTo("a\\b"))
    assertThat(line.done(), equalTo(true))
  }

  func test_popDelimitedString_unmatchedDelimeter_returnsNil() {
    let line = ScriptLine(line: "sed /foooo +")
    let found = line.popDelimitedString()
    assertThat(found, equalTo(nil))
  }

  func test_popDelimitedStringArray_happyPath() {
    let line = ScriptLine(line: "sed /abc/def/ghi/")
    let found = line.popDelimitedStringArray(numElements: 3)
    assertThat(found!, contains("abc", "def", "ghi"))
    assertThat(line.done(), equalTo(true))
  }

  func test_popDelimitedStringArray_moreCharacters_goIntoRest() {
    let line = ScriptLine(line: "sed /abc/def/ghi")
    let found = line.popDelimitedStringArray(numElements: 2)
    assertThat(found!, contains("abc", "def"))
    assertThat(line.done(), equalTo(false))
    assertThat(line.rest(), equalTo("ghi"))
  }

  func test_popDelimitedStringArray_moreCharactersAfterSpace_goIntoRestWithoutSpace() {
    let line = ScriptLine(line: "sed /abc/def/ ghi")
    let found = line.popDelimitedStringArray(numElements: 2)
    assertThat(found!, contains("abc", "def"))
    assertThat(line.done(), equalTo(false))
    assertThat(line.rest(), equalTo("ghi"))
  }

  func test_popDelimitedStringArray_notEnoughTerminators_returnsNil() {
    let line = ScriptLine(line: "sed /abc/def/ghi")
    let found = line.popDelimitedStringArray(numElements: 3)
    assertThat(found, equalTo(nil))
  }

}
