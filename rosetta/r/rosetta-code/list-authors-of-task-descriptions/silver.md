# Rosetta Code/List authors of task descriptions

**Excluded from Silver: network.** The task needs HTTP fetching of Rosetta Code pages, which is an effect Silver lacks, not a conflict. A Silver-friendly solution can use a fixed-capacity array of task names and a fixed-capacity array of (author, count) records instead of the linked map, a loop over the tasks, and iterative parsing of the fetched HTML and history text, with no assertions, exceptions or recursion. The only other needs are a console report and bounded arrays sized above the observed 1360 tasks and 280 authors, which the Oracle permits as documented limits.

## Language surface recorded by this assessment

Integers, characters, string operations, arrays, records, loops and subprograms.

## External effects

- **network** (not allowed): Fetches Rosetta Code category pages and per-task revision history pages over HTTP(S) to collect the task list and author of each revision history.
- **console output** (allowed): Prints the progress lines and the final ranked table of authors with at least nine tasks.

Assessed on 2026-10-15 against page revision 415122 of the [task](https://rosettacode.org/wiki/Rosetta_Code/List_authors_of_task_descriptions) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
