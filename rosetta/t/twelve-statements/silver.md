# Twelve statements

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for loops over fixed ranges with small Boolean arrays and bounded counters, so checks follow from types and simple guards and no variants or invariants are needed. The only non-routine parts are loop-carried counters and quotients, which need guards or subtype bounds.

Position 408 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Enumerate all 4096 truth assignments with a for loop over a ranged integer, decode each into a 12-element Boolean array using rem and division by 2 in an inner for loop, then evaluate the twelve statements with a counting function over array slices (guarded counters) and count mismatches against the claimed values. A procedure prints the true statement numbers with Put and Integer'Image for assignments with zero mismatches, and a second pass does the same for exactly one mismatch, adding the contradicted statement number. About 95 lines.

## Proof obligations to watch

- **overflow**: The truth counters in loops are loop-carried, so each increment is guarded by a test that the counter is below 12 (its subtype bound), which discharges the range check without changing results.
- **index**: Statement indexes are constants 1..12 or for-loop variables over the table's own range, so every access is statically in bounds.
- **range**: Decoding each assignment number 0..4095 into bits uses rem and division by the literal 2 on a loop-carried quotient, which stays in range only through its subtype bound.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the exact hits and the near-miss table to standard output.

Assessed on 2026-10-15 against page revision 414557 of the [task](https://rosettacode.org/wiki/Twelve_statements) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
