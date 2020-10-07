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
        let script = "~ FNORD FJORD"
        let (result, commands) = sut.parse(script: script)
        
        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(FilterLineCommand.self))
        
        let cmd = commands[0] as! FilterLineCommand
        _ = cmd.validate()
        assertThat(cmd.pattern, equalTo("FNORD FJORD"))
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

    func test_parse_today_recognizesIt() {
        let sut = givenScriptParser()
        let script = "today"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(TodayCommand.self))
    }

    func test_parse_loadFilterRequired_recognizesIt() {
        let sut = givenScriptParser()
        let script = "require FNORD FJORD"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(LoadFilterCommand.self))

        let cmd = commands[0] as! LoadFilterCommand
        _ = cmd.validate()
        assertThat(cmd.loadFilterType, equalTo(LoadFilterCommand.LoadFilterType.Required))
        assertThat(cmd.pattern, equalTo("FNORD FJORD"))
    }

    func test_parse_loadFilterExcluded_recognizesIt() {
        let sut = givenScriptParser()
        let script = "exclude FNORD FJORD"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(LoadFilterCommand.self))

        let cmd = commands[0] as! LoadFilterCommand
        _ = cmd.validate()
        assertThat(cmd.loadFilterType, equalTo(LoadFilterCommand.LoadFilterType.Excluded))
        assertThat(cmd.pattern, equalTo("FNORD FJORD"))
    }

    func test_parse_loadFilterClear_recognizesIt() {
        let sut = givenScriptParser()
        let script = "clearFilters"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(LoadFilterCommand.self))

        let cmd = commands[0] as! LoadFilterCommand
        _ = cmd.validate()
        assertThat(cmd.loadFilterType, equalTo(LoadFilterCommand.LoadFilterType.Clear))
    }

    func test_parse_loadFilterRequireToday_recognizesIt() {
        let sut = givenScriptParser()
        let script = "requireToday"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(LoadFilterCommand.self))

        let cmd = commands[0] as! LoadFilterCommand
        _ = cmd.validate()
        assertThat(cmd.loadFilterType, equalTo(LoadFilterCommand.LoadFilterType.RequireToday))
    }

    func test_parse_limit_recognizesIt() {
        let sut = givenScriptParser()
        let script = "limit 1234"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(LimitCommand.self))

        let cmd = commands[0] as! LimitCommand
        _ = cmd.validate()
        assertThat(cmd.limit, equalTo(1234))
    }


    func test_parse_sql_recognizesIt() {
         let sut = givenScriptParser()
        let sql = "SELECT A,B FROM C WHERE D;  SELECT X FROM Y;"
         let script = "sql \(sql)"
         let (result, commands) = sut.parse(script: script)

         assertThat(result, equalTo(true))
         assertThat(commands.count, equalTo(1))
         assertThat(commands[0], instanceOf(SqlCommand.self))

         let cmd = commands[0] as! SqlCommand
         assertThat(cmd.sql, equalTo(sql))
     }

    func test_parse_sortByFieldsCommand_recognizesIt() {
        let sut = givenScriptParser()
        let script = "sort fnord"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(SortByFieldsCommand.self))

        let cmd = commands[0] as! SortByFieldsCommand
        _ = cmd.validate()
        assertThat(cmd.fields, equalTo(["fnord"]))
    }

    func test_parse_addFieldCommand_recognizesIt() {
        let sut = givenScriptParser()
        let script = "@ a b"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(AddFieldCommand.self))

        let cmd = commands[0] as! AddFieldCommand
        _ = cmd.validate()
        assertThat(cmd.fieldToAdd, equalTo("a"))
        assertThat(cmd.fieldToMatch, equalTo("b"))
    }

    func test_parse_divideByFieldCommand_recognizesIt() {
        let sut = givenScriptParser()
        let script = "/f a"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(DivideByFieldCommand.self))

        let cmd = commands[0] as! DivideByFieldCommand
        _ = cmd.validate()
        assertThat(cmd.field, equalTo("a"))
    }

    func test_parse_divideByRegexCommand_recognizesIt() {
        let sut = givenScriptParser()
        let script = "/r a b"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(DivideByRegexCommand.self))

        let cmd = commands[0] as! DivideByRegexCommand
        _ = cmd.validate()
        assertThat(cmd.pattern, equalTo("a b"))
    }

    func test_parse_filterByStory_recognizesIt() {
        let sut = givenScriptParser()
        let script = "/= FNORD FJORD"
        let (result, commands) = sut.parse(script: script)

        assertThat(result, equalTo(true))
        assertThat(commands.count, equalTo(1))
        assertThat(commands[0], instanceOf(FilterStoryCommand.self))

        let cmd = commands[0] as! FilterStoryCommand
        _ = cmd.validate()
        assertThat(cmd.pattern, equalTo("FNORD FJORD"))
    }

    func givenScriptParser() -> ScriptParser {
        let callback = ScriptCallbackStub()
        return ScriptParser(callback: callback)
    }
    
}
