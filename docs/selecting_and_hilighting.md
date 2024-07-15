### Selecting and Hilighting Log Lines

TODO -- THIS PAGE IS STILL UNDER CONSTRUCTION

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

![Example1](./images/example1.png)



## Filtering by Today's date

You can always filter lines by the current date with an explicit filter, for example `= 2019-08-17`.

To avoid modifying your script every day, use the commands `today` and `requireToday` instead.  These commands dynamically create a filter based on the current date.

By default, the format used is `MM.dd.YY`.  You can replace this with another format using the `dateFormat` command, for example `dateFormat YYYY-MM-dd`.
