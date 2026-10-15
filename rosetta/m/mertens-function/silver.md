# Mertens function

**Candidate: proofs plausibly discharge automatically.** All bounds come from array ranges and small ranged subtypes, with every loop-carried quantity (running sum, sieve products, counters) either type-bounded or guarded before use, and no recursion, while loops in functions or annotations are needed. The work lies in careful guard placement for nonlinear index products and the running sum, hence plausible rather than likely.

Position 175 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Compute a Moebius array (Integer range -1..1, indices 1..1000) with a prime sieve using for loops and guarded index products, then build the Mertens array as a running sum with a range guard, and count zeros and crossings in one for loop. Print the first 99 terms in a 9-by-11 grid by formatting each value into a fixed 4-character padded buffer with 'Image and Put, using a Put_Line at each row end, then print the two counts. About 70 lines.

## Proof obligations to watch

- **index**: Sieve indexes such as i*k are nonlinear, so each loop guards the product against 1000 immediately before indexing.
- **overflow**: The running Mertens sum is loop-carried and known only by its type, so an explicit range guard before each addition rejects out-of-range values and also discharges the grid column arithmetic.
- **range**: Negating the Moebius value and assigning the running sum to a ranged subtype need guards because only type ranges are known inside loops.
- **length**: Padded number text is built in a fixed-length buffer sized for the widest 3-character value, with a guard before each slice or copy.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 99-term grid and the zero and crossing counts.

Assessed on 2026-10-15 against page revision 414339 of the [task](https://rosettacode.org/wiki/Mertens_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
