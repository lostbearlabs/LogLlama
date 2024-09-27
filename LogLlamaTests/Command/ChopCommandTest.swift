import SwiftHamcrest
import XCTest

@testable import LogLlama

class ChopCommandTest: XCTestCase {
  func test_run_twoLines_removesHiddenOne() {
    // arrange
    let ctx = CommandTestContext()
    let sut = ChopCommand()
    let _ = sut.setup(callback: ctx, line: ScriptLine(line: ""))
    ctx.addLines(numLines: 3)
    // hide line #1
    ctx.lines[1].visible = false

    // act
    _ = sut.run(logLines: &ctx.lines, runState: &ctx.runState)

    // assert
    // line #1 should have been removed, and lines should have been renumbered
    assertThat(ctx.lines.count, equalTo(2))
    assertThat(ctx.lines[0].lineNumber, equalTo(1))
    assertThat(ctx.lines[1].lineNumber, equalTo(2))
  }
}
