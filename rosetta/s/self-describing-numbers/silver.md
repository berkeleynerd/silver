# Self-describing numbers

**Candidate: proofs likely to discharge automatically.** Everything is bounded for loops over ranged integers and fixed ten-element arrays, so index, range and overflow checks follow from types plus a trivial guard on the tally increments, with no need for annotations.

Position 1499 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

A function takes a number in a ranged subtype 0..10**10-1, extracts up to ten digits with a fixed for loop over 0..9 using mod and / on a remaining value, stores them in a ten-element digit array while tallying counts in a ten-element count array, and records the digit length. It then compares digit(p) with count(p) for each position below the length with a for loop and returns the Boolean. The main procedure loops over 1..100_000_000 in a for loop and prints each hit with 'Image through Put_Line, with no while loops or recursion. About 45 lines.

## Proof obligations to watch

- **range**: The digit-count increments are loop-carried, so each increment is guarded by a test that the count is below its subtype maximum, which never changes the result for numbers of at most ten digits.
- **index**: Digit values come from mod 10 on a non-negative bounded value and positions come from a for loop over 0..9, so every array index is within 0..9 by type.
- **overflow**: The tested number is a ranged subtype below 10**10 within 64-bit range, and the scan loop variable is bounded by the same subtype, so the arithmetic is bounded.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, Boolean objects, arrays, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each self-describing number found, one per line.

Assessed on 2026-10-15 against page revision 413543 of the [task](https://rosettacode.org/wiki/Self-describing_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
