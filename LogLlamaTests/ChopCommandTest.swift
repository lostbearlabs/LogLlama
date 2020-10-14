import XCTest
import Hamcrest
@testable import LogLlama

class ChopCommandTest: XCTestCase {
    func test_run_twoLines_removesHiddenOne() {
        // arrange
        let ctx = CommandTestContext()
        let sut = ChopCommand(callback: ctx)
        ctx.addLines(numLines: 3);
        // hide line #1
        ctx.lines[1].visible = false

        // act
        _ = sut.run(logLines: &ctx.lines, runState: &ctx.runState)

        // assert
        // line #1 should have been removed
        assertThat(ctx.lines.count, equalTo(2))
        assertThat(ctx.lines[0].lineNumber, equalTo(1))
        assertThat(ctx.lines[1].lineNumber, equalTo(3))
    }
}
