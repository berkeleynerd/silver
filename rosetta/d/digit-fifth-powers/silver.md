# Digit fifth powers

**Candidate: proofs likely to discharge automatically.** Every check follows from the declared range of N and the digit indexes, with a single guarded loop-carried Sum, so the proofs should discharge without annotations.

Position 130 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A constant 10-entry array holds d**5 for each digit d, and a for loop runs N over 2..999_999 (numbers above 354294 cannot qualify, so six digits suffice). For each N the digit sum is an unrolled six-term expression over N mod 10, (N / 10) mod 10 and so on, so no while loop or loop-carried digit accumulator is needed. Matches are printed through 'Image, and Sum is a ranged integer updated only after a guard against exceeding its limit, which rejects otherwise. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Sum is the only unbounded accumulator, and an explicit guard before each addition rejects visibly if the limit would be exceeded, while the per-number digit sum is a loop-free six-term expression bounded by the table values.
- **index**: The power table is indexed by digit expressions such as N mod 10 and (N / 10) mod 10 that are provably 0..9 from the non-negative range of N.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each matching number and the final sum with Put_Line.

Assessed on 2026-10-15 against page revision 415400 of the [task](https://rosettacode.org/wiki/Digit_fifth_powers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
