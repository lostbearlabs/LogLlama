# LlamaScript Command Reference

## Standard Commands

At any time, you can find this same list of commands in "Reference" pane within the application.

```
*** COMMENTS ***
# comment           -- ignore the contents of any line starting with #

*** ADDING LOG LINES ***
require regex       -- when loading lines, filter out any that don't match regex
exclude regex       -- when loading lines, filter out any that do match regex
requireToday        -- when loading lines, filter out any that don't contain the current date
clearFilters        -- clear any line loading filters
< file name/pattern -- load log lines from matching files in order created
demo                -- generate sample log lines programmatically
limit N             -- truncate files with > N lines
replace a b         -- when importing lines, replace any occurence of a with b
sort field1 field2  -- sort lines according to field list, with text comparison as the last condition

*** FILTERING/HILIGHTING LOG LINES ***
: color             -- hilight following matches with (color)
= regex             -- hide all lines not matching regex
+ regex             -- unhide all lines matching regex
- regex             -- hide all lines matching regex
~ regex             -- hilight regex without changing which lines are hidden
==                  -- hide all lines not already hilighted
today               -- hide all lines that don't contain today's date
dateFormat          -- set the date format for subsequent "today" and "requireToday" lines

*** REMOVING LOG LINES ***
chop                -- remove all hidden lines
clear               -- remove ALL lines

*** ADJUSTING LOG LINES ***
truncate N          -- truncate lines with > N characters
@ field1 field2     -- populate lines that have field2 but not field1 with the value from another line that has field1 and the same value of field2

*** ANALYSIS ***
d N                 -- identify lines duplicated more than N times
sql ...             -- run specified SQL command against extracted fields

*** SECTIONS ***
/r regex            -- mark lines that match regex as section headers
/f field            -- mark lines where the value of field changes as section headers
/= regex            -- hide any sections that don't have a line matching regex
/- regex            -- hide any sections that do have a line matching reges

```

## Commands for testing LogLlama itself

The following commands are implemented but do not appear in the "Reference" pane:

```
sleep N              -- suspend script execution for N seconds.  This is useful for testing the UI state while a script is busy.
```