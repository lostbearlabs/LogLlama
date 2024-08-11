import SwiftHamcrest
import XCTest

@testable import LogLlama

class AddFieldCommandTest: XCTestCase {
  func test_run_linkingFieldExists_copiesDependentField() {
    // arrange
    let ctx = CommandTestContext()
    let sut = AddFieldCommand(
      callback: ctx, fieldToAdd: "dependentField", fieldToMatch: "linkField")
    ctx.addLines(numLines: 2)
    ctx.lines[0].namedFieldValues.updateValue("linkValue", forKey: "linkField")
    ctx.lines[1].namedFieldValues.updateValue("linkValue", forKey: "linkField")
    ctx.lines[1].namedFieldValues.updateValue("dependentValue", forKey: "dependentField")

    // act
    _ = sut.run(logLines: &ctx.lines, runState: &ctx.runState)

    // assert
    assertThat(ctx.lines[0].namedFieldValues["dependentField"], equalTo("dependentValue"))
  }
}
