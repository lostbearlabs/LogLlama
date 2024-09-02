import SwiftHamcrest
import XCTest

@testable import LogLlama

class SedCommandTest: XCTestCase {

  func test_setup_justCommand() {
    // arrange
    let ctx = CommandTestContext()
    let sut = SedCommand()

    // act
    let rc = sut.setup(callback: ctx, line: ScriptLine(line: "sed +"))

    // assert
    assertThat(rc, equalTo(true))
    assertThat(sut.action, equalTo(.unhide))
  }

  func test_setup_lineRangeAddress() {
    // arrange
    let ctx = CommandTestContext()
    let sut = SedCommand()

    // act
    let rc = sut.setup(callback: ctx, line: ScriptLine(line: "sed 2,5 -"))

    // assert
    assertThat(rc, equalTo(true))
    assertThat(sut.action, equalTo(.hide))
    assertThat(sut.address?.range?.0, equalTo(2))
    assertThat(sut.address?.range?.1, equalTo(5))
  }

  func test_setup_lineAddress() {
    // arrange
    let ctx = CommandTestContext()
    let sut = SedCommand()

    // act
    let rc = sut.setup(callback: ctx, line: ScriptLine(line: "sed 2 -"))

    // assert
    assertThat(rc, equalTo(true))
    assertThat(sut.action, equalTo(.hide))
    assertThat(sut.address?.range?.0, equalTo(2))
    assertThat(sut.address?.range?.1, equalTo(2))
  }

  func test_setup_regexAddress() {
    // arrange
    let ctx = CommandTestContext()
    let sut = SedCommand()

    // act
    let rc = sut.setup(callback: ctx, line: ScriptLine(line: "sed /abc/ -"))

    // assert
    assertThat(rc, equalTo(true))
    assertThat(sut.action, equalTo(.hide))
    assertThat(sut.address?.regex?.pattern, equalTo("abc"))
  }

}
