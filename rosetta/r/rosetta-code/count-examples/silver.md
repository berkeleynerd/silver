# Rosetta Code/Count examples

**Excluded from Silver: network.** The Silver-friendly solution fetches the Programming_Tasks category list and each task's raw wikitext over HTTP, scans each line for the "=={{header|" marker, and prints per-task and total counts. The only missing capabilities are network access and fixed-capacity text buffers for titles and response lines, which the Oracle's bounded-resource rule permits. Nothing in the task requires a run-time error, exceptions, assertions or unsafe constructs. Confidence is medium because the network effect and the bounded-capacity behavior for an unbounded category listing are design choices.

## Language surface recorded by this assessment

Integers, characters, string operations, arrays and loops.

## External effects

- **network** (not allowed): Fetches the category member list and each task's raw wiki page from the Rosetta Code MediaWiki API over HTTP.
- **console output** (allowed): Prints one line per task with its example count, then the grand total.

Assessed on 2026-10-15 against page revision 413887 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Count_examples) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
