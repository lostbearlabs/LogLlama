# LogLlama

## Overview

LogLlama is a log analysis and exploration tool for OS X.  

LogLlama's unique approach combines:
* Scripted input, making it easy to share log analysis steps with your teammates.
* Graphical output, making it easy to see patterns in the log and review contextual information.

## Example

Here is a sample script.  It reads the log of an automobile race and performs some filtering and hilighting.

```
< /tmp/race.txt

: yellow
~ LAP 2

# : lightgreen
# = STARTED

# : lightblue
# + FINISHED

# : red
# + CRASHED
```

Here is what the screen looks like after running this script:

![Example1][https://raw.githubusercontent.com/lostbearlabs/LogLlama/master/documentation/example1.png]

## Script Documentation

For a list of available commands, see the "Reference" pane within the application.

## Contributing

GitHub issues and pull requests are both welcome.

