# Binomial transform

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over fixed array ranges with small embedded data, so indexes are routine and only the loop-carried accumulators and Pascal sums need explicit range guards with a visible reject outcome, which makes automatic discharge plausible rather than certain.

Position 931 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the four 15-element sequences as constant Long_Long_Integer arrays and build a 15x15 Pascal triangle table in a nested for loop with a bounded-sum guard. Procedures apply the forward and inverse transforms with for loops over the array range, choosing the sign by parity of n-k, and guard the accumulator before every add, rejecting on failure. A formatting procedure appends each value's image to a bounded String buffer and prints it with Put_Line, covering forward, inverse and round-trip lines. About 130 lines.

## Proof obligations to watch

- **overflow**: Each transform accumulator is loop-carried and only known by its type after the first iteration, so each addition is guarded against a declared bound and rejects otherwise, which the 64-bit values for 15 terms (under 1e11) never reach.
- **range**: Pascal-triangle entries are built by adding two previous row entries held in a ranged subtype, so a guard before each store is needed and the maximum C(14,7)=3432 stays far below the bound.
- **length**: Number-to-text conversion into a fixed output buffer needs a capacity sized for 15 values of at most 12 digits plus sign and separator, with guards on the write position.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, 'Image of scalars, string building, for loops, procedures, functions, Put without a newline, characters and conditional expressions.

## External effects

- **console output** (allowed): Prints each sequence and its forward, inverse and round-trip transforms as text lines.

Assessed on 2026-10-15 against page revision 414636 of the [task](https://rosettacode.org/wiki/Binomial_transform) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
