# Numbers with prime digits whose sum is 13

**Candidate: proofs likely to discharge automatically.** Every check is a range or division-by-ten on bounded integer subtypes with for loops only and a guard before each accumulation, so the proofs follow from types and local guards with no annotation needed.

Position 135 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A for loop runs N over 1 .. 322222 (the largest possible answer, since seven digits sum to at least 14), and an inner fixed six-iteration for loop peels digits off a copy of N using mod 10 and / 10, accepting a digit only if it is 2, 3, 5 or 7 and the running sum stays at most 13 (guard before the add). Digits are tracked in a Natural-range remainder, a Boolean ok flag, and a 0..13 sum, and numbers with ok and sum exactly 13 are printed with Put_Line of the integer image. About 35 lines.

## Proof obligations to watch

- **overflow**: The digit-sum accumulator is a subtype 0..13 and the addition is guarded by a test just before it, so the range check discharges without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects and for loops.

## External effects

- **console output** (allowed): Prints each matching number on its own line.

Assessed on 2026-10-15 against page revision 406167 of the [task](https://rosettacode.org/wiki/Numbers_with_prime_digits_whose_sum_is_13) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
