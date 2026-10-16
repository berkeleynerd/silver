# Rosetta Code/Find unimplemented tasks

**Excluded from Silver: network.** The Silver-friendly solution fetches the two category lists through paged API requests (looping on the continue token), stores titles in bounded arrays with a documented capacity, computes the set difference with nested loops, and prints the result. Nothing in the task requires an error, exception, assertion, or unsafe construct, so no conflict arises; the needs are network access, a command-line argument and text output, plus bounded-collection features that Silver can admit as explicit resource limits.

## Language surface recorded by this assessment

Arrays, loops, string operations, subprograms and integers.

## External effects

- **arguments** (allowed): The language name is taken from the first command-line argument.
- **network** (not allowed): The program must query the Rosetta Code MediaWiki API over HTTPS to fetch the category member lists for Programming_Tasks and for the chosen language.
- **console output** (allowed): The program prints the titles of tasks not implemented in the given language, and the count.

Assessed on 2026-10-15 against page revision 413889 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Find_unimplemented_tasks) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
