# Keyboard macros

**Candidate: proofs likely to discharge automatically.** Every check is an array index by Character or a guarded line index, with no contracts needed, since all loops are in procedures and the dispatch is a plain case statement. The GUI tag is satisfied by line-based key presses, so no window or raw keystrokes are required.

Position 1214 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

An enumeration Action (Greet, Count, Quit, None) and a Character-indexed array of Action serve as the application-specific key-binding table, initialised with an aggregate and rebound at run time by a Bind procedure. Main loops over stdin lines in a while loop inside a procedure, looks up the first character of each non-empty line in the table and runs the matching procedure through a case statement. Empty lines and unbound keys get an explicit message, and the counter is a bounded integer that stops at its limit with a visible outcome. About 70 lines.

## Language surface recorded by this assessment

Characters, enumerations, arrays, procedures, case statements, while loops, standard input, string indexing, integers and for loops.

## External effects

- **standard input** (allowed): Each input line supplies one key press whose bound action is run.
- **console output** (allowed): Each bound action reports itself by printing a line.

Assessed on 2026-10-15 against page revision 411154 of the [task](https://rosettacode.org/wiki/Keyboard_macros) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
