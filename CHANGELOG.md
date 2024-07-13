# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.4.0] - 2024-07-13
- Tune up build so it compiles and runs again. Switch from CocoaPods to Swift Package Manager.
- Add "New with demo"

## [1.3.0] - 2020-10-19
- Add "limit N" command to restrict the number of file lines read
- Add "sort field" command to sort lines by a specific field
- Add "@" command to copy fields from lines to linked lines
- Add "/r" and "/f" commands to create sections
- Add "/-" and "/=" commands to hide sections

## [1.2.0] - 2020-02-11
- Add "Show Line Detail" menu command to surface action previously only discoverable via double-click.
- Add "dateFormat" command to specify the date format used by "today" and "requireToday"
- Add "sql" command to query named fields in log data using SQL syntax

## [1.1.0] - 2019-10-19 
- Show current script file name in window title
- Add support for glob patterns when loading log files with `<`
- Add `require`, `exclude`, `requireToday`, and `clearFilter` commands to pre-filter lines as they are loaded.
- Save font size between runs
- Correct error in column width calculation that led to log lines not filling the entire results pane

## [1.0.1] - 2019-10-15
- First release
