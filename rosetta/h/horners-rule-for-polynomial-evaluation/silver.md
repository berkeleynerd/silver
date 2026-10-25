# Horner's rule for polynomial evaluation

**Candidate: proofs plausibly discharge automatically.** Index checks discharge from the reverse for loop over Coeffs'Range. The only non-routine checks are overflow and range checks on the loop-carried accumulator's nonlinear multiply-add, and a guard on the accumulator placed just before each step makes them provable without an invariant.

Position 992 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Coefficients are an unconstrained array of a bounded coefficient subtype (for example -1000 .. 1000), and the example data (-19, 7, -4, 6) with x = 3 is embedded. A Horner procedure walks the array's own range in reverse with a for loop and returns the value and an Ok flag through out parameters; before each multiply-add it checks that the accumulator is within a documented bound, and otherwise it sets Ok to False and leaves the accumulator unchanged. Main prints the value with 'Image, or prints a visible "result exceeds limit" message when Ok is False. About 40 lines.

## Proof obligations to watch

- **overflow**: The loop-carried accumulator product Res * X is nonlinear, so it discharges only because a guard checks that Res is within a documented bound just before each step and declared ranges bound X and every coefficient; if the guard fails, the routine sets Ok to False instead of computing.
- **range**: Assigning Res * X + Coeffs (I) back to the bounded accumulator subtype needs the guarded bound on Res combined with the coefficient and X ranges, so the bound constants must be chosen so the worst-case result fits the accumulator subtype.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, unconstrained arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the evaluated polynomial value (128) with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 411617 of the [task](https://rosettacode.org/wiki/Horner's_rule_for_polynomial_evaluation) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
