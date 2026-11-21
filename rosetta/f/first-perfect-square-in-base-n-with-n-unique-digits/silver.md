# First perfect square in base n with n unique digits

**Candidate: proofs plausibly discharge automatically.** All values for bases 2 to 12 fit in a bounded 64-bit range, and every loop-carried value (root, counter, buffer position) is bounded by its subtype or a guard just before use, so no annotation is needed, though the several loop-carried guards make discharge depend on careful program shape.

Position 1092 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

For each base in a for loop over 2..12, compute the starting root by incrementing a ranged integer while r*r is below base**(base-1), then search upward with a while loop in a procedure, testing the square by extracting digits with rem and / into a 12-entry Boolean seen array and counting distinct digits against the base. Digits of the root and its square are converted to characters into fixed-size String buffers by a procedure with explicit position guards, then printed with Put_Line (or Put plus Put_Line) in the form 'Base N: root^2 = square'. About 90 lines.

## Proof obligations to watch

- **overflow**: The root n is a ranged subtype capped at about 2**31 and n*n is computed in a 64-bit type, with a guard before each increment that reports failure if the cap is reached, so no overflow can occur.
- **index**: Digit values come from rem by a base in 2..12 and index a Boolean array of 0..11, and digit text goes into a fixed buffer sized for 13 digits, with a guard on the write position before each store.
- **termination**: The search and digit-extraction while loops live in procedures, which get no termination check, and the search is capped at the root limit so it ends in a visible reject if nothing is found.
- **range**: The unique-digit counter is a loop-carried value that is only incremented under a guard count < 12, so its subtype range holds without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, string building, string indexing, unconstrained arrays, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): One line per base 2 through 12 showing the root and its square in that base.

Assessed on 2026-10-15 against page revision 415312 of the [task](https://rosettacode.org/wiki/First_perfect_square_in_base_n_with_n_unique_digits) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
