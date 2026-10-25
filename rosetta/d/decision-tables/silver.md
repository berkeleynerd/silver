# Decision tables

**Candidate: proofs likely to discharge automatically.** All data is fixed-size and indexed by enumeration types, loops are for loops over static ranges, and the only dynamic risk is end of input, which a guard handles, so every check follows from types and bounds.

Position 1212 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Define enumerations for conditions and actions, a Boolean array indexed by condition, and a constant array of 13 rule records (answers plus action) embedded in the program. A procedure asks each question with Put and reads one character from stdin (end of input counts as 'no'), then a for loop over the rules compares the answer array with each rule and prints the matching action, falling back to a 'no idea' message if none matched. About 70 lines.

## Proof obligations to watch

- **other**: Reading an answer may hit end of input, so the program treats missing input as 'no' (or rejects) with a specified outcome rather than raising an exception.

## Language surface recorded by this assessment

Enumerations, ranged subtypes, Boolean objects, characters, arrays, records, for loops, case statements, procedures, Put without a newline and standard input.

## External effects

- **standard input** (allowed): Answers to the three printer questions are read as characters from standard input.
- **console output** (allowed): Prompts and recommended actions are printed to the console.

Assessed on 2026-10-15 against page revision 407487 of the [task](https://rosettacode.org/wiki/Decision_tables) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
