# Search a list

**Excluded from Silver: exception handling.** Searching a bounded array of strings for the smallest index of a needle is easy to do in Silver with a loop and string comparison. However, the task explicitly requires raising an exception when the needle is missing, and Silver forbids that, so the sample is excluded.

## Language surface beyond today's Silver

Arrays, string operations, loops, integers and subprograms.

## Oracle conflicts

- **exception handling**: The task explicitly says to raise an exception when the needle is missing from the haystack. Silver admits no raised exceptions (rule 2), and SPARK does not allow exception handlers (rule 8), so this requirement cannot be met as written.

## External effects

- **console output** (allowed): Prints the index found for each needle, or the not-found outcome.

Assessed on 2026-10-15 against page revision 411635 of the [task](https://rosettacode.org/wiki/Search_a_list) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
