# Euler's sum of powers conjecture

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges of the index and power subtypes and from guards in the binary search, with no recursion and no loop-carried accumulator, but nonlinear power building and the while-loop search need careful typing to discharge.

Position 241 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Precompute a constant-sized table of fifth powers for 0..250 in a subtype-bounded array, then run four nested for loops over strictly increasing a, b, c, d in 1..249 forming the sum from table entries, and binary-search the table for y with a while loop in a procedure. A Found Boolean guards the loops after the first hit, and the result is printed with Put and 'Image, with a defined message if none is found. About 80 lines.

## Proof obligations to watch

- **overflow**: Fifth powers up to 250^5 and sums of four up to 4*250^5 fit a declared 64-bit range type, but building each power by repeated multiplication needs a tightly ranged subtype per intermediate product (square, cube, fourth) so the provers see nonlinear bounds.
- **overflow**: Sums are formed fresh from table entries of type Fit inside each loop iteration, so no loop-carried accumulator exists and the sum bound follows from the entry subtype.
- **index**: The binary search for y over the power table carries lo, hi and mid through a while loop with no invariant, so each is typed to the index range and mid is computed as lo + (hi - lo) / 2 under a guard lo <= hi, which discharges from types.
- **range**: For loops with A+1 style lower bounds are kept in range by limiting the outer indexes below 249 so the successor stays inside the Base subtype.
- **termination**: The while-loop binary search lives in a procedure, which gets no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, integer division, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the five numbers a b c d y of the found solution on one line.

Assessed on 2026-10-15 against page revision 413707 of the [task](https://rosettacode.org/wiki/Euler's_sum_of_powers_conjecture) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
