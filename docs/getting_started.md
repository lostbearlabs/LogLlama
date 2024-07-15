# Getting Started

## Working with scripts

In LogLlama, you load and work with log data using scripts.  Here's an example:

```
# Read log file
< ~/Desktop/sample.log

# Hilight the word "Example" in green
: lightgreen
~ Example
```

You can type scripts into the script panel in the top left of the LlogLlama window like this:

![LlogLlama window](./images/getting_started_1.png)

You can load and save scripts as text files using the following menu commands:

- `File ... New Script`
- `File ... New Script with demo`
- `File ... Open Script`
- `File ... Recent Scripts`

![File menu](./images/getting_started_2.png)


## Loading Log Data

The usual way to load data is using the script command `<`, for example:

```
< ~/Desktop/sample.log
```

Because LogLlama is a sandboxed application, your script can only load files from disk this way if you grant full disk access.  
In your System Settings, navigate to "Privacy and Security ... Full Disk Access" and make sure LogLlama is present and enabled.

If you do not want to grant full disk access to LogLlama, you can log log data manually using the menu command `File ... Load log...`

## Demo Log Data

Many of the examples in this documentation use randomly generated log data.  You can generate random log lines using the `demo` command:

```
# Generate random sample data
demo
```


