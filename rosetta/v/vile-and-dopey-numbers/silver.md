# Vile and Dopey numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from small declared ranges, fixed-length for loops and arrays indexed by guarded counts, with no recursion and no annotations needed, so proofs should discharge routinely. The only care needed is keeping the loop-carried counters in wide types and avoiding a while loop inside the function.

Position 360 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

An Is_Vile function takes a value in 1 .. 1024, runs a for loop of 11 steps that halves it while it is even and flips a parity Boolean, and returns the parity. A procedure scans n from 1 to 1024 in a for loop, storing the first 25 of each kind in two fixed arrays of 25, and a second pass keeps running counts and prints a row of counts each time n reaches a power of two from 2 to 1024. Output uses Put and 'Image with small padding logic that is bounded by the digit counts. About 70 lines.

## Proof obligations to watch

- **overflow**: The running Vile and Dopey counters are loop-carried, so they are declared with a range far above 1024 (for example 0 .. 1_000_000) so that incrementing them cannot overflow without an invariant.
- **termination**: The trailing-zero parity test is a function, so it uses a for loop with a fixed 11 iterations and a done flag instead of a while loop that would need a variant.
- **range**: Halving the loop-carried value inside the parity test is guarded by testing that it is even and nonzero immediately before dividing.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the two 25-number lists and the ten-row count table with Put and Put_Line.

Assessed on 2026-10-15 against page revision 405889 of the [task](https://rosettacode.org/wiki/Vile_and_Dopey_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
