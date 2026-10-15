# Pi to 1 million digits

**Candidate: proofs plausibly discharge automatically.** Every check follows from range-subtyped limbs, carries and for-loop indexes over the array's own range, with all while loops in procedures, so no annotation is needed, but the large fixed-capacity big-number arithmetic carried through nested loops makes discharge depend on careful program shape.

Position 1382 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Represent pi as a fixed-capacity array of base-10^9 limbs (about 111,200 limbs, a documented resource limit) with 64-bit range-subtype arithmetic, and compute it with Machin's formula using procedures for divide-by-small-integer, add and subtract that sweep the array with for loops and a typed carry or remainder. A while loop in a procedure iterates the arctan series terms with a bounded term counter, and the program then converts the first 52 and last 50 digits into a bounded Character buffer and prints them with Put_Line, skipping the optional timing. About 140 lines.

## Proof obligations to watch

- **overflow**: Limb arithmetic (limb*small multiplier plus carry, and remainder*base plus limb) stays within 64 bits because limb, multiplier and carry are range subtypes, and any single guard is placed immediately before the operation.
- **index**: Every array access runs over a for-loop index on the array's own range or a guarded computed index, so no loop-carried index needs an invariant.
- **termination**: All while loops (the series term loop) live in procedures, which get no termination check, and the term counter is a bounded range.
- **range**: Carries and quotients are narrowed into limb subtypes only after an explicit guard or by construction from the division by the base, which provers handle for a constant base.
- **other**: A Machin-style series over a fixed array of about 112,000 base-10^9 limbs needs roughly 10^11 limb operations, so it proves easily but runs for minutes, which is a performance cost and not a proof cost.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, procedures, big numbers, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first and last several digits of pi to standard output.

Assessed on 2026-10-15 against page revision 413849 of the [task](https://rosettacode.org/wiki/Pi_to_1_million_digits) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
