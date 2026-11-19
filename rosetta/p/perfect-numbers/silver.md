# Perfect numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from the Candidate range, the for-loop index range and one explicit guard before the accumulator addition, so no annotation is needed and the proofs should discharge.

Position 312 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare a bounded subtype Candidate of Positive range 1 .. 10000 as the documented resource limit, and write a function Is_Perfect(N : Candidate) that loops I over 1 .. N - 1, adding I to Sum when N mod I = 0 and leaving the loop first if Sum > N. Main loops over the candidates with a for loop and prints each perfect number with Put_Line (Candidate'Image (N)), which gives 6, 28, 496 and 8128. About 35 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried with no invariant, so an explicit guard before the addition leaves the loop once the sum exceeds N, which keeps Sum + I within Integer without changing the result.
- **division**: The divisor I comes from a for loop starting at 1, so the range of I rules out a zero divisor in N mod I.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the perfect numbers found in an embedded range, one per line.

Assessed on 2026-10-15 against page revision 414393 of the [task](https://rosettacode.org/wiki/Perfect_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
