# Tau function

**Candidate: proofs likely to discharge automatically.** Trial division with nested for loops over static ranges needs only range-typed counters and mod with a loop-index divisor, so every check follows from types and one visible guard; only output formatting needs new library surface.

Position 146 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A main procedure loops N over 1 .. 100 and an inner for loop D over 1 .. N counts divisors with N mod D = 0 into a Count variable of subtype 0 .. 100, guarding the increment with Count < 100. Each row of ten counts is built into a bounded fixed-size String line by padding the 'Image text of each count to a fixed width, then printed with Put_Line (or Put for each cell and Put_Line to end the row). No recursion or while loops are needed, and all bounds are static. About 45 lines.

## Proof obligations to watch

- **overflow**: The divisor counter is bounded by the loop range (at most 100 increments) and typed as a small range subtype, so increments are guarded by the type's upper bound or a Count < limit check.
- **division**: The mod divisor is the for-loop index over 1 .. N, whose type range excludes zero, so the division check discharges from the loop range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the divisor counts for 1 to 100 as ten rows of ten numbers.

Assessed on 2026-10-15 against page revision 413079 of the [task](https://rosettacode.org/wiki/Tau_function) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
