# Zeckendorf arithmetic

**Candidate: proofs plausibly discharge automatically.** All checks are index and capacity bounds on loop-carried positions that can be guarded explicitly in procedures without invariants, but carry/borrow normalization and the multiplication and division tables need careful shaping, so discharge is plausible rather than routine.

Position 476 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A Zeckendorf number is a fixed-capacity array of 0..1 digits (about 40 positions) with the task's examples embedded as constant digit strings. Add, subtract, multiply (doubling table of shifted values and adding) and divide (greedy subtract of table entries) are procedures that apply digit-wise operations then normalize 11 to 100 with guarded while loops, with explicit capacity checks that report overflow. Output converts digit arrays to a String via a bounded buffer and Put_Line. About 170 lines.

## Proof obligations to watch

- **index**: Carry and borrow propagation move loop-carried digit indexes left and right, so each access is guarded explicitly against the array bounds before use.
- **overflow**: Results exceeding the fixed digit capacity must take a visible outcome (reporting overflow and leaving the value unchanged) via a guard before carrying past the top digit.
- **termination**: Normalization is written as while loops inside procedures only, which get no termination check, and any function uses for loops only.
- **initialization**: Every digit array is fully initialized by aggregate or a for loop before use, and out parameters are assigned on all paths.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions and string building.

## External effects

- **console output** (allowed): Prints the Zeckendorf results of the addition, subtraction, multiplication and division examples as digit strings.

Assessed on 2026-10-15 against page revision 414597 of the [task](https://rosettacode.org/wiki/Zeckendorf_arithmetic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
