# Montgomery reduction

**Candidate: proofs plausibly discharge automatically.** Small fixed-radix integer arithmetic in a for loop is checkable from types and a pre-addition guard on the one loop-carried accumulator, so no annotation is needed, though a 100-bit big-number version like the existing solution would need fixed-capacity digit arrays and be harder.

Position 374 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use the task's radix-10 example (m = 72639, b = 10, n = 5, m' = 1, T = 7118368) with a constant table of powers of b, a single Reduce procedure over a bounded 64-bit integer subtype, and a for loop over digit positions 0 to n-1 that extracts a_i by division and mod, forms u_i, and adds u_i*m*b^i after a guard. After the loop it divides by b^n, subtracts m once if the result is at least m, and prints the result through scalar image text with Put_Line, rejecting out-of-range input visibly. About 70 lines.

## Proof obligations to watch

- **overflow**: The accumulator A is carried through the loop so GNATprove knows only its type range, hence an explicit guard before each A + u*m*b^i rejects (with a printed message) any case where the sum would exceed the declared maximum.
- **range**: The digit u_i = (a_i * m') mod b is bounded by the radix type, and the power b^i comes from a constant table indexed by the loop variable, so these are routine once A is guarded.
- **division**: The divisions by b^i and b^n use table entries that are static positive constants, so nonzero divisors follow from the array's declared range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars, string building, procedures and functions.

## External effects

- **console output** (allowed): Prints the radix, digit count, inputs and reduced result with Put_Line.

Assessed on 2026-10-15 against page revision 406392 of the [task](https://rosettacode.org/wiki/Montgomery_reduction) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
