# LogLlama

## Overview

LogLlama is an interactive log analysis and exploration tool for OS X.  

LogLlama's unique approach combines:
* Scripted input, making it easy to share log analysis steps with your teammates.
* Graphical output, making it easy to see patterns in the log and review contextual information.

## Example

Here is a sample script.  It reads the log of an automobile race and performs some filtering and hilighting.

```
< /tmp/race.txt

: yellow
~ LAP=2

: lightgreen
= STARTED

: lightblue
+ FINISHED

: red
+ CRASHED
```

Here is what the screen looks like after running this script:

![Example1](https://raw.githubusercontent.com/lostbearlabs/LogLlama/master/documentation/example1.png)

## Script Documentation

For a list of available commands, see the "Reference" pane within the application.

## Tips and Tricks

* Most of the actions you can perform are listed in the main menu.  These include loading and saving script files, running the script, and changing the font size.
* All script commands are listed in the `Reference` pane.
* If you have script text selected in the editor, then the `Run` menu command will run only the selected text instead of the entire script.  This makes it easy to interactively explore your log file.  
* During interactive exploration, a script line that just says `clear` can be used to reset your output.
* During interactive exploration, the `Undo` menu command can be used to undo whatever line(s) of script you just ran.
* During interactive exploration, use the script command `==` to distil your display down to only hilighted lines and then the menu command `Undo` to revert.
* If a log line is annoyingly long, double click to display it in a resizable popup that wraps text.

## Filtering by Today's date

You can always filter lines by the current date with an explicit filter, for example `= 2019-08-17`.

To avoid modifying your script every day, use the commands `today` and `requireToday` instead.  These commands dynamically create a filter based on the current date.

By default, the format used is `MM.dd.YY`.  You can replace this with another format using the `dateFormat` command, for example `dateFormat YYYY-MM-dd`.

## SQL Queries

LogLlama can convert log lines with field/value pairs to a SQL table, allowing you to perform any legal SQLite query against the data.

Any log text matching the regular expression `(\w+)=(\w+)` is treated as a field/value pair.  Field names discovered this way are listed in the output from the `<` command that reads the log file.

The SQL table that receives the data is named `log`.

In addition, you can create your own field value pairs by using named groups in your pattern maching expressions.  Here is an example with the canned demo data:

```
demo

~ car (?<num>\d+) STARTED

sql select min(num), max(num),avg(num) from log where num is not null
```

## Sections

LogLama can divide log lines into sections and selectively hide sections.  For example:

```
demo

# populate each line with the car number
~ car (?<num>\d+)

# sort according to car number
sort num

# create one section each time the car number changes
/f num

# only show sections that include a crash
/= CRASHED


```


## Contributing

GitHub issues and pull requests are both welcome.
