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

  func givenData(numLines: Int) -> LogLineArray {
    var ar = LogLineArray()
    for i in 0..<numLines {
      let line = LogLine(text: "Line \(i), mod3=\(i%3), div3=\(i/3)", lineNumber: i)
      ar.append(line)
    }
    return ar
  }

}
