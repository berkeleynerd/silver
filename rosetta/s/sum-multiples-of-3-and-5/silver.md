# Sum multiples of 3 and 5

**Candidate: proofs likely to discharge automatically.** The closed-form series sum needs only bounded integer arithmetic on ranged subtypes and one fixed output line, so every check follows from declared types with no loops or annotations. The optional 1e20 extra credit is omitted, and the required n = 1000 case is covered faithfully.

Position 298 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare a ranged subtype Limit_Range (1 .. 10**9) and a function Multiples_Sum (Step, Last) that uses the arithmetic-series formula (Last / Step) * (Step * ((Last / Step) + 1)) / 2 over a 64-bit integer type. Sum_35 (Limit) returns Multiples_Sum (3) + Multiples_Sum (5) - Multiples_Sum (15) for Last = Limit - 1. Main calls it with the constant 1000 and prints "n=1000: " & the 'Image of the result (233168); the loop-based form is avoided because a loop-carried accumulator could not be proven free of overflow without an invariant. About 28 lines.

## Proof obligations to watch

- **overflow**: The closed-form arithmetic k*(k+1)*step is bounded by a declared Limit range of at most 10**9 in a 64-bit integer type, so every intermediate fits and the checks follow from types alone, with no loop-carried accumulator.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the sum for n = 1000 with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413418 of the [task](https://rosettacode.org/wiki/Sum_multiples_of_3_and_5) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
