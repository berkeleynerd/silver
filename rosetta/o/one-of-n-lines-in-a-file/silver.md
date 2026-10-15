# One of n lines in a file

**Candidate: proofs plausibly discharge automatically.** All loops are for loops with fixed bounds and every arithmetic value is bounded by subtype ranges or a visible guard, so no annotation is needed, though the LCG arithmetic and counter guard require careful shape.

Position 1299 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

A procedure One_Of_N takes N (subtype 1..10) and an in out LCG state of a bounded integer subtype, loops I in 1..N advancing the state and setting Choice := I when (state mod I) = 0 (probability 1/I), and returns Choice in 1..10. Main runs a for loop of 1,000,000 simulations using a fixed seed, increments a Results array (1..10) of bounded counters behind a cap guard, then prints each count with Put and Integer'Image. The deterministic generator replaces system randomness and the repetition count is the task's full 1,000,000. About 45 lines.

## Proof obligations to watch

- **overflow**: The LCG step multiplies a state bounded below 2**31 by a constant below 2**31, so the product fits in 64 bits and is reduced with mod, which follows from the subtype ranges alone.
- **overflow**: Each count is incremented in a loop with no invariant, so the program guards the increment with a comparison against the 1,000,000 cap and rejects visibly if it were reached, which cannot happen for the fixed run count.
- **range**: The chosen line index is assigned from a for-loop variable over 1 .. N into a subtype 1 .. 10, so the array index check follows from types.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and modular types.

## External effects

- **console output** (allowed): The ten per-line counts are printed to standard output.

Assessed on 2026-10-15 against page revision 414369 of the [task](https://rosettacode.org/wiki/One_of_n_lines_in_a_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
