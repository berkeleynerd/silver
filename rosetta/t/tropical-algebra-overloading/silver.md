# Tropical algebra overloading

**Candidate: proofs plausibly discharge automatically.** All arithmetic is on small bounded fixed-point values with explicit range guards before each addition and a for-loop power, so no annotation is needed, but fixed-point image formatting, the loop-carried accumulator guard, and the -Inf record make careful program shape necessary.

Position 1576 in the [progression](../../progression.md#stage-38), in stage 38.

## Approach

Represent a tropical value as a record holding a Boolean Is_Neg_Inf flag and a bounded fixed-point value (delta 0.001, range roughly +/-1.0E6), with Tropical_Add (max, with -Inf as identity) and Tropical_Mul (sum, -Inf absorbing, guarded against leaving the range) as expression functions or small functions. Power is a for loop over 1 .. B with B a positive bounded subtype, guarding each addition before performing it, and a procedure prints each required demonstration (2 times -2, -0.001 plus -Inf, 0 times -Inf, 1.5 plus -1, -0.5 times 0, 5 to the 7th, and the distributivity comparison) via Put_Line with 'Image text. About 80 lines.

## Proof obligations to watch

- **overflow**: Tropical multiplication adds two fixed-point values and the exponent loop accumulates repeated sums, so each addition is guarded by a range test that visibly rejects an out-of-range result rather than saturating.
- **range**: The loop-carried power accumulator is known only by its type after the first iteration, so the guard before each addition must be explicit and the exponent is a bounded positive subtype.
- **other**: Representing real numbers by a bounded decimal fixed-point type with a separate negative-infinity flag is a documented resource limit that covers the task's example values (-0.001, 1.5, -0.5) exactly.

## Language surface recorded by this assessment

Fixed point, records, Boolean objects, ranged subtypes, integers, functions, procedures, for loops, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): Prints each demonstrated identity and result line to standard output.

Assessed on 2026-10-15 against page revision 413095 of the [task](https://rosettacode.org/wiki/Tropical_algebra_overloading) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
