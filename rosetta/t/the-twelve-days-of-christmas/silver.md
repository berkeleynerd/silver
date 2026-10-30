# The Twelve Days of Christmas

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every branch is a case over the full subtype range, so no run-time checks depend on loop-carried values and nothing needs an annotation. The task needs only fixed embedded text output, so no guards, recursion, or heap are involved.

Position 780 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Define a subtype Day_Number is Integer range 1 .. 12 and two procedures with exhaustive case statements over it: one prints the ordinal line for a day and the other prints the gift line for a day (with a Boolean flag choosing "And a partridge" versus "A partridge"). The main body uses an outer for loop over Day_Number and an inner reverse for loop from the current day down to 1, then prints a blank line after each verse. About 80 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, case statements, for loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints the carol lyrics line by line to standard output.

Assessed on 2026-10-15 against page revision 415311 of the [task](https://rosettacode.org/wiki/The_Twelve_Days_of_Christmas) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
