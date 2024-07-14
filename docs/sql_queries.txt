# SQL Queries

TODO -- THIS PAGE IS STILL UNDER CONSTRUCTION

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
