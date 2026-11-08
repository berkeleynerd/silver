# Digital root

**Candidate: proofs plausibly discharge automatically.** The task needs only bounded integer arithmetic, array iteration and text output, and the sole non-routine checks are loop-carried sums and counters that need explicit guards but no annotations.

Position 231 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Represent numbers as a ranged 64-bit integer subtype and hold the embedded test numbers in a constant array, then a Compute procedure repeatedly replaces the number by its digit sum (using mod 10 and / 10) while it is at least 10, counting rounds. Accumulators and the counter are guarded before each addition so overflow checks follow from explicit conditions, and results are printed with Put_Line using 'Image concatenation, in base 10 only. About 70 lines.

## Proof obligations to watch

- **overflow**: The digit-sum accumulator is loop-carried and GNATprove knows only its type after the first iteration, so each addition is guarded by a bound check, with a specified reject outcome rather than a silent change, that is never true for the 64-bit embedded inputs.
- **range**: The persistence counter in the outer while loop is also loop-carried and needs a bounded type with a guard before each increment, which is safe because digit sums shrink the number but that fact is not visible to the prover.
- **termination**: The while loops live inside a procedure so no termination check applies, and the inner digit loop can alternatively be a for loop over a fixed 19 digit positions.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each embedded number with its additive persistence and digital root.

Assessed on 2026-10-15 against page revision 412745 of the [task](https://rosettacode.org/wiki/Digital_root) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
