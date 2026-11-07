# Padovan sequence

**Candidate: proofs plausibly discharge automatically.** Everything is for loops over fixed arrays and buffers in procedures, with the only non-routine checks being guarded integer additions, a guarded float power accumulation with a rounding conversion, and a capacity guard on string building, so no annotation is needed.

Position 872 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Fixed arrays of 64 capped-range integers hold the recurrence terms (for loop with guarded addition) and the floor-based terms (Float power accumulator with range guard, rounded to an integer), and Boolean flags record whether they agree. The L-system keeps the current string in a 4500-character buffer plus a length, and a for loop over its characters appends the rule expansion (A to B, B to C, C to AB) into a second buffer with a capacity guard before each append; the lengths of strings 0..31 are stored and compared with the recurrence terms. Output uses Put_Line and Put with 'Image for integers, and an overflow guard reports a visible failure message. About 130 lines.

## Proof obligations to watch

- **overflow**: The recurrence sums loop-carried array values, so each term is held in a subtype capped near 10**12 and a guard before the addition rejects (with a visible message) any sum above the cap, though P(63) is only about 5e7 so the guard never fires for 64 terms.
- **floating point**: The floor-based method multiplies a loop-carried Float by the plastic ratio 63 times, so the accumulator is a bounded float subtype with a guard before each multiplication and the result is range-checked before conversion to an integer, which provers can discharge but it needs careful shape.
- **index**: L-system strings of up to 4410 characters are built in a fixed 4500-character buffer whose length is a ranged subtype, with a guard before each append that rejects on overflow of capacity.
- **range**: Converting the rounded floating value to the integer term type needs a range guard just before the conversion, with a visible 'differ' outcome rather than silent clamping.
- **termination**: All iteration uses for loops in procedures, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, floating point, arrays, string indexing, string building, 'Image of scalars, for loops, procedures, functions, case statements and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 20 terms, the equality verdict, the first 10 L-system strings and the length-check verdict.

Assessed on 2026-10-15 against page revision 414378 of the [task](https://rosettacode.org/wiki/Padovan_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
