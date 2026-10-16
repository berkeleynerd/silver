# Super-d numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over ranged integers and a fixed digit array, so no annotations are needed, but carry/length checks in loop-carried digit arithmetic and the search limit require careful guards. Extra credit d of 7 to 9 is optional and omitted.

Position 1374 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

For each d from 2 to 6, a procedure iterates n upward (bounded by a documented limit), computes d*n^d into a fixed-capacity little-endian decimal digit array by repeated small-integer multiplication with carry, then scans the digits with a for loop for a run of d equal digits d. Hits are counted until 10 are found and printed on one line with Put and Integer'Image, with an explicit failure outcome if the limit is reached. About 90 lines.

## Proof obligations to watch

- **overflow**: d*n^d exceeds 64 bits for d of 5 and 6, so the power is computed in a fixed-capacity decimal digit array, and each digit*n+carry step is bounded by ranged subtypes for the digit, carry and a documented search limit on n.
- **index**: The digit-array length grows with each multiplication, so each step must guard length against the array capacity (sized for 6*limit^6) and reject otherwise, which is a visible outcome.
- **termination**: The search for 10 hits is a while loop in a procedure (no termination check), with an explicit upper limit on n and a specified Reject-style outcome if fewer than 10 are found.
- **range**: Loop-carried carry and length values need type ranges or guards before use because no invariants can be written, which constrains program shape.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, big numbers, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 10 super-d numbers for each d from 2 to 6 as text lines.

Assessed on 2026-10-15 against page revision 413936 of the [task](https://rosettacode.org/wiki/Super-d_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
