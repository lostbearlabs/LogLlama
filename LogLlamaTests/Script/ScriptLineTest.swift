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

}
