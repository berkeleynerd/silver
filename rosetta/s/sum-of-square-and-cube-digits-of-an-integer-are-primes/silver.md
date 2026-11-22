# Sum of square and cube digits of an integer are primes

**Candidate: proofs likely to discharge automatically.** Every check follows from the loop index range, ranged subtypes and fixed unrolled digit extraction with no while loops or loop-carried accumulators, so proofs should discharge without annotations. The only new Silver surface is integer arithmetic, small functions, a for loop and integer-to-text output.

Position 335 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A for loop over I in 5..99 computes the square and cube into ranged subtypes (0..9801 and 0..970299), and a non-recursive function sums digits by explicit division and mod for each of six fixed digit positions. An Is_Prime function tests a sum (at most 54) by a for loop over divisors 2..7 with a Boolean result, and qualifying I values are printed with Put of an image of I followed by a space, ending with a newline. About 45 lines.

## Proof obligations to watch

- **overflow**: The digit sum is computed as an unrolled six-term expression over a bounded subtype (cube at most 970299), so no loop-carried accumulator exists and the sum fits trivially.
- **range**: The conversion of N*N*N into the cube subtype is discharged from the declared range of the loop index 5..99, which solvers handle with bounded nonlinear multiplication.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the qualifying numbers 16 17 25 28 34 37 47 52 64 to standard output.

Assessed on 2026-10-15 against page revision 406228 of the [task](https://rosettacode.org/wiki/Sum_of_square_and_cube_digits_of_an_integer_are_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
