# Primes whose first and last number is 3

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by a ranged subtype and every loop is a for loop over static bounds, so all checks follow from types and no loop invariant is needed.

Position 130 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A ranged subtype N of 3..3999 is iterated with a for loop, keeping candidates with n mod 10 = 3, and the leading digit is found by dividing a copy by 10 in a fixed three-iteration for loop guarded by a value-at-least-10 test. Primality is a Boolean flag set by an inner for loop over d in 2..63 testing d*d <= n and n mod d = 0, and each prime found is printed with Put_Line of its image (Put can lay out several per line). The stretch count below 1,000,000 is left out as optional. About 35 lines.

## Proof obligations to watch

- **overflow**: d*d with d at most 63 and n in 3..3999 are bounded by declared ranges, so no overflow check can fail.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each qualifying prime with Put_Line.

Assessed on 2026-10-15 against page revision 387125 of the [task](https://rosettacode.org/wiki/Primes_whose_first_and_last_number_is_3) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
