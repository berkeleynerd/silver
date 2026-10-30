# Jordan-Pólya numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged types and guards before each multiplication and append, with loops confined to procedures, but the loop-carried counters and the dedupe-and-sort shape need careful guarding, so discharge is plausible rather than routine.

Position 253 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a bounded array of distinct J-P numbers up to 100 million, starting from 1; for each factorial 2! through 11! held in a constant array, walk the array (including newly appended entries) and append x*f when x <= Limit/f and the value is not already present, then insertion-sort and print the first 50 and the last entry via Integer'Image-style text conversion. The bonus decompositions are skipped as optional. A full list is bounded by a capacity constant and a visible rejection if it were exceeded. About 90 lines.

## Proof obligations to watch

- **index**: The generation loop appends to a fixed-capacity array, so each append is guarded by a count-below-capacity test that otherwise rejects visibly, and capacity is sized well above the real count under 100 million.
- **overflow**: Products x*f are computed only after a guard x <= Limit / f in a 64-bit range type, and the loop-carried count and cursor are typed with ranges that bound them.
- **termination**: All while loops sit inside procedures, which get no termination check, and the inner multiplication loop strictly grows its value toward the limit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 Jordan-Polya numbers and the largest one below 100 million.

Assessed on 2026-10-15 against page revision 412861 of the [task](https://rosettacode.org/wiki/Jordan-P%C3%B3lya_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
