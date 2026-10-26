# Jensen's Device

**Candidate: proofs plausibly discharge automatically.** The task is a 100-term floating-point harmonic sum that needs only a for loop, a nonzero divisor from the index range and one overflow guard on the accumulator, so no annotation is needed; the main uncertainty is the float overflow check on the loop-carried accumulator.

Position 1031 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Define a Sum function over a loop index subtype 1 .. 100 that accumulates 1.0 / Float (I) in a Float with a for loop, guarding the accumulator against overflow before each addition, and have Main print Float'Image of the result with Put_Line. Call by name is realized by writing the term expression directly in the summation loop, since Silver has no access-to-subprogram or by-name parameters. About 28 lines.

## Proof obligations to watch

- **floating point**: The Float accumulator is only known by its type after the first iteration, so the addition's overflow check needs an explicit guard before each add with a visible rejection otherwise.
- **division**: The divisor Float(I) is nonzero because I is a for-loop index over the subtype 1 .. 100, which discharges routinely.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, for loops and functions.

## External effects

- **console output** (allowed): Prints the computed harmonic sum (about 5.18738) to standard output.

Assessed on 2026-10-15 against page revision 412859 of the [task](https://rosettacode.org/wiki/Jensen's_Device) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
