import XCTest
import Hamcrest
@testable import LogLlama

class ScriptParserTest: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func test_parse_comment_ignoresIt() {
        let sut = givenScriptParser()
        let script = "# comment"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(0))
    }

    func test_parse_readFile_recognizesIt() {
        let sut = givenScriptParser()
        let script = "< foo.txt"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(ReadFileCommand.self))
        
        let cmd = commands[0] as! ReadFileCommand
        assertThat(cmd.file, equalTo("foo.txt"))
    }
    
    func test_parse_demo_recognizesIt() {
        let sut = givenScriptParser()
        let script = "demo"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(DemoCommand.self))
    }

    func test_parse_detectDuplicatesWithWrongNumberArguments_failsIt() {
        let sut = givenScriptParser()
        let script = "dd"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(false))
        assertThat(commands.count, equalTo(0))
    }

    
    func test_parse_color_recognizesIt() {
        let sut = givenScriptParser()
        let script = ": blue"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(ColorCommand.self))
        
        let cmd = commands[0] as! ColorCommand
        _ = cmd.validate()
        assertThat(cmd.color, equalTo(NSColor(hexString: "#0000FFFF")))
    }

    func test_parse_chop_recognizesIt() {
        let sut = givenScriptParser()
        let script = "chop"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(ChopCommand.self))
    }
    
    func test_parse_clear_recognizesIt() {
        let sut = givenScriptParser()
        let script = "clear"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(ClearCommand.self))
    }

    func test_parse_detectDuplicates_recognizesIt() {
        let sut = givenScriptParser()
        let script = "d 99"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(DetectDuplicatesCommand.self))
        
        let cmd = commands[0] as! DetectDuplicatesCommand
        assertThat(cmd.threshold, equalTo(99))
    }

    func test_parse_filter_recognizesIt() {
        let sut = givenScriptParser()
        let script = "~ FNORD"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(FilterCommand.self))
        
        let cmd = commands[0] as! FilterCommand
        _ = cmd.validate()
        assertThat(cmd.pattern, equalTo("FNORD"))
    }

    func test_parse_truncate_recognizesIt() {
        let sut = givenScriptParser()
        let script = "truncate 512"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(TruncateCommand.self))

        let cmd = commands[0] as! TruncateCommand
        assertThat(cmd.maxLength, equalTo(512))
    }

    func test_parse_requireHilight_recognizesIt() {
        let sut = givenScriptParser()
        let script = "=="
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(RequireHilightCommand.self))
    }


    
    
    func givenScriptParser() -> ScriptParser {
        let callback = ScriptCallbackStub()
        return ScriptParser(callback: callback)
    }
    
}
