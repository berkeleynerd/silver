# Gapful numbers

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by a 64-bit-safe range type and a fixed-count digit loop, so overflow, division and termination checks follow from types and local guards with no annotations; the only slightly delicate parts are the loop-carried counter and the fixed search window.

Position 884 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

A bounded Value subtype (0..2**40) is used; a function Divisor strips digits with a fixed 10-iteration for loop (dividing by 10 only when the value is at least 10) and returns 10*first + N mod 10, with a guard returning 1 for N below 100. A procedure Find_Gapful(From, Count) runs a for loop over From .. From + a fixed search window, tests N mod Divisor(N) = 0, prints each hit with Put and 'Image, and guards the Found counter against exceeding Count before exiting. Main calls it three times with Put_Line titles and New_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: Divisor computation and the Found counter are loop-carried, so a 64-bit range type and a guard (Found < Count) before each increment make them safe without an invariant.
- **termination**: Digit stripping uses a fixed 10-iteration for loop instead of a while loop, so the function needs no variant.
- **division**: The divisor is 10*first digit + last digit with first digit at least 1 for N at least 100, which the prover must see from guarded division by 10 (an explicit guard N >= 100 on the function or a rejecting branch covers it).

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, functions, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints three titled lines of numbers to standard output.

Assessed on 2026-10-15 against page revision 415503 of the [task](https://rosettacode.org/wiki/Gapful_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
