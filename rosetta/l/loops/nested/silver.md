# Loops/Nested

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges, for-loop indexes over the array's own bounds and a ranged seed type, so the proofs should discharge without annotations; the only growth needed is arrays, for loops, mod and Put.

Position 1533 in the [progression](../../../progression.md#stage-33), in stage 33.

## Approach

Declare a constrained 10x10 array of a 1..20 subtype and fill it in nested for loops using a deterministic linear congruential generator over a ranged seed (next = (seed*75+74) mod 65537, value = seed mod 20 + 1). Then print with nested for loops over the array's own ranges, emitting each element's image with Put, and use a named outer loop with exit Outer when the element equals 20, ending each completed row with a line terminator. All indexes come from the array's own ranges, so no guards are needed. About 35 lines.

## Proof obligations to watch

- **overflow**: The LCG seed is loop-carried through the fill loops, but a seed subtype 0..65536 makes seed*75+74 fit in Integer and the mod result is within the subtype range, so no invariant is needed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, 'Image of scalars, Put without a newline, procedures and block statements.

## External effects

- **console output** (allowed): Prints the visited array elements on one line per row to standard output.

Assessed on 2026-10-15 against page revision 415008 of the [task](https://rosettacode.org/wiki/Loops/Nested) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
