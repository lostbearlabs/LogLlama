# Frequently Asked Questions

## Can I tail an active log file?

Not yet.  But stay 'tooned, this is on the roadmap!

## Why not just use grep and sed?

Much of what you might use LogLlama for can also be accomplished with grep and sed.  However LogLlama 
also offers the following additional capabilities:

- You can hide parts of your log using `-` and then un-hide a subset of those lines using `+`.  This kind of logical filtering requires more complicated regular expressions when using the standard command line tools.
- You can selectively apply and then undo parts of your script as you explore your log contents.
- You can search within your search results (Using the search box at the bottom of the results panel) without filtering or regenerating the results themselves
- You can parse fields from your log data, load them into SQLite in memory, and then perform queries against your log fields.
- You can partition your log into logical sections and then selectively hide or show sections.

## Speaking of sed, can I search and replace, insert lines, or perform other operations?

This is also on the roadmap!

## Why not use SumoLogic or Splunk?

Online log tools offer similar functionality.  SumoLogic's `logreduce` command was an inspiration for LogLlama's (less powerful) `d N` command.
LogLlama's SQL queries were written before I knew how to perform those queries in any online tool but they are similar in motivation.

The main difference is that LogLlama is for working with files on your local drive, not in the cloud.  You may have customer logs that
you don't want to upload to a cloud provider, or you may simply not want to to deal with the logistics or cost of uploading logs.

