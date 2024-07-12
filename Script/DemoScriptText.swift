import Foundation

var demoScriptText = """
# Each commented section of this demo script is intended to run separately.
#
# Select the section you want to run and then choose "Script ... Execute"
#
# You can run the whole file at once if you don't select a section, but since each
# demo clears the log as it starts, the result is just like if you run the last
# section alone.
#
# The demo race data is randomly generated, so you will see different results
# as you run multiple times.

# Example 1: create demo log and hilight race starts in Blue and crashes in Red
demo
: lightblue
~ \\*\\*\\* Race \\d+ \\*\\*\\*
: red
~ CRASHED

# Example 2: show all starts, stops, and crashes for car 2
clear
demo
: lightgreen
= car=2
- event=LAP

# Example 3: just show races where car 1 crashes
clear
demo
- event=LAP
: lightgreen
/r \\*\\*\\* Race \\d+ \\*\\*\\*
: red
~ car=1, event=CRASHED
/= car=1, event=CRASHED


"""

