# Working With Sections

TODO -- THIS PAGE IS STILL UNDER CONSTRUCTION

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
