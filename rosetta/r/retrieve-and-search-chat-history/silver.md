# Retrieve and search chat history

**Excluded from Silver: network, clock.** The task fetches dated chat log files over HTTP, splits them into lines and prints the lines that contain a command-line substring. No fixed Oracle rule gets in the way: what it needs is a network library operation and a clock, plus bounded date arithmetic and substring search, all of which a future Silver could admit with documented size limits.

## Language surface recorded by this assessment

Integers, string operations, loops, arrays, subprograms and records.

## External effects

- **network** (not allowed): Must fetch the last 10 days of chat log files from http://tclers.tk/conferences/tcl/ over HTTP, and detect a missing log so a not-found page is not printed.
- **clock** (not allowed): Needs the current date (in Europe/Berlin, or local date plus one extra day) to work out the ten YYYY-MM-DD log file names.
- **arguments** (allowed): The substring to search for comes from a command-line argument.
- **console output** (allowed): Prints each log URL, the ------ separator lines and the matching lines.

Assessed on 2026-10-15 against page revision 413883 of the [task](https://rosettacode.org/wiki/Retrieve_and_search_chat_history) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
