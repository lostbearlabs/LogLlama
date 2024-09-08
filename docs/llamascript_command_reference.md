# LlamaScript Command Reference

## List of Commands

At any time, you can find this same list of commands in "Reference" pane within the application.

```

*** COMMENTS ***
# comment              --ignore the contents of any line starting with #

*** ADDING LOG LINES ***
< file name/pattern    --load log lines from matching files in order created
clearFilters           --clear any line loading filters
demo [N]               --generate sample log lines for N (default 3) races programmatically
exclude regex          --when loading lines, filter out any that do match regex
limit N                --truncate files with > N lines
replace A B            --when importing lines, replace any occurence of A with B
require regex          --when loading lines, filter out any that do not match regex
requireToday           --when loading lines, filter out any that don't contain the current date

*** ADJUSTING LOG LINES ***
@ field1 field2        --populate lines that have field2 but not field1 with the value from another line that has field1 and the same value of field2
truncate N             --truncate lines with > N characters

*** ANALYSIS ***
d N                    --identify lines duplicated more than N times
kv regex               --parse lines for key/value pairs.  Regex must specify named groups "key" and "value".
sql ...                --run specified SQL command against extracted fields

*** FILTERING/HILIGHTING LOG LINES ***
+ regex                --unhide all lines matching regex
- regex                --hide all lines matching regex
:  color               --hilight following matches with (color)
= regex                --hide all lines not matching regex
==                     --hide all lines not already hilighted
dateFormat regex       --set the date format for subsequent "today" and "requireToday" lines
today                  --when loading lines, filter out any that don't contain the current date
~ regex                --hilight regex without changing which lines are hidden

*** MISC ***
sleep N                --sleep for N seconds (for testing UI updates during script processing)
sort field1, field2, ... --sort lines according to field list, with line number comparison as the last condition
sed COMMAND            --run sed command

*** REMOVING LOG LINES ***
chop                   --remove all hidden lines
clear                  --remove ALL lines

*** SECTIONS ***
/- regex               --hide any sections that have a line matching regex
/= regex               --hide any sections that don't have a line matching regex
/f field               --mark lines where the value of field changes as section headers
/r regex               --mark lines that match regex as section headers

```

