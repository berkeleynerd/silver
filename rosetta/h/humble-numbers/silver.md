# Humble numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded arrays, ranged integers and procedure while loops, so checks follow from types and guards just before each use; the main care is guarding the loop-carried merge pointers and the stored values without invariants.

Position 265 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Compute humble numbers with the standard four-pointer merge (multiples of 2, 3, 5, 7) into a fixed-capacity array of a 64-bit range type, in a while loop inside a procedure, stopping once the next value exceeds 10^9 (about 5200 terms, with the array sized with margin). Then tally each value's decimal digit count into a small array indexed by digit count, using a bounded division loop. Finally print the first 50 numbers on one line and one row per digit count using integer-to-text conversion into bounded buffers, with guards before every pointer advance and array store. About 95 lines.

## Proof obligations to watch

- **overflow**: Candidate products 2h to 7h are computed on a 64-bit range type whose element bound is far below the type limit, so the multiplications by constants discharge, and a value is stored only after a guard comparing it to the digit limit.
- **index**: The four merge pointers are loop-carried in a while loop with no invariant, so each is declared with the array's index subtype and its increment is guarded by a comparison with the array's last index, giving a visible stop outcome rather than a silent clamp.
- **range**: Digit counting by repeated division by 10 and the per-digit counter increments rely on the digit-count array index type and counter types having ample range, with a guard before each increment.
- **termination**: All loops live in procedures, which get no termination check, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 humble numbers on one line and the per-digit-count table, one row per line.

Assessed on 2026-10-15 against page revision 414260 of the [task](https://rosettacode.org/wiki/Humble_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
