# sed Syntax

## Introduction

For some actions, LogLlama follows the syntax of the Linux command-line utility `sed`.  For an overview of `sed`, see for example [A Visual Guide To Sed](https://betterprogramming.pub/a-visual-guide-to-sed-a7a8abd2f675).

In LogLlama, sed syntax takes the following form:

```
sed [address] command [arguments]
```

* The address indicates which log lines should be processed.  This is optional, and if it's omitted, then all lines are processed.  Three forms of address are recognized:
  * `10` - a single number indicates a line to be processed
  * `10,20` - a pair of numbers indicates a line range to be processed
  * `/x=\d+/` - a regular expression indicates that any line with a match should be processed
  
* The command is required and indicates how to process the specified lines.

* The arguments are specific to the command.

If the address is a regular expression, then its first character is treated as a delimiter and must be used to end the expression:

```
/abc/
|abc|
```

Within a regular expression, the backslash character is used to escape both the delimiter and any other backslash.  Do not use a backslash as your deliieter.

```
/abc\/def\\ghi|jkl/       => abc/def\ghi|jkl
|abc/def\\ghi\|jlk//      => abc/def/ghi|jkl
\abc\                     => NO
```



## Commands

The following commands are implemented:

| Command      | Description |
| ------------ | ----------- |
| `+`          | Un-hide any matching lines |
| `-`          | Hide any matching lines |
| `~`          | Hilight matches in any matching lines |
| `s/regex/text/[g]` | replace `regex` with `text`. |


The filtering and hilighting commands (`+`, `-`, and `~`) work the same way as their regular counterparts, but the 
sed-style addressing option gives new flexibility for hiding and unhiding lines.  For example, if you have identified
line 1000 as significant and want to ensure the 100 previous lines are visible so you can see what let up to the 
significant event, you could write `sed 900-1000 +`.

The replace command `s` supports a single replacement (`g` not specified) or global replacement (`g` specified).  No other flags 
are supported.  References in the replacement text are not supported either.

## Differences from sed

* Only the commands listed above are supported.  `sed` has many other capabilities that are not (yet?) implemented in LogLlama
* Some commands are LogLlama-specific.  For example, hiding and unhiding lines are new concepts in LogLlama that don't apply in regular `sed`.
* A space is allowed between the command and any arguments.
* Command arguments can have any delimeter, just as a regex address can.

