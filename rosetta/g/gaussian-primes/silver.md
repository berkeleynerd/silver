# Gaussian primes

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes and for-loop indexes, with no loop-carried accumulators and only for loops inside functions, so proofs should discharge without annotations.

Position 529 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A function Is_Prime over a subtype 0..5000 tests divisors with a for loop over 2..70 guarded by d*d<=N, and Is_Gaussian_Prime(A,B) over subtype -50..50 applies the task's axis rule (|x| mod 4 = 3 and prime) or the norm rule. A nested for loop over A,B lists primes with norm below 100 using Integer'Image and Put, then nested for loops fill a fixed 101-character row string with '*' or space for each point and print it with Put_Line for radius 50. All indices come from for-loop ranges matching the subtypes, so no loop-carried invariants are needed. About 70 lines.

## Proof obligations to watch

- **overflow**: Coordinates are subtypes of -50..50 so a*a+b*b is at most 5000, which the provers bound easily despite the nonlinear multiplication.
- **division**: The mod divisor is a for-loop index over 2..70, so it is statically nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, functions, procedures and Put without a newline.

## External effects

- **console output** (allowed): The list of primes and the text-art plot are written to standard output.

Assessed on 2026-10-15 against page revision 413992 of the [task](https://rosettacode.org/wiki/Gaussian_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
