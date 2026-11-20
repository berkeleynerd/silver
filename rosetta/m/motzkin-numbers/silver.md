# Motzkin numbers

**Candidate: proofs plausibly discharge automatically.** All values fit in 64 bits and every operation can be guarded from the type range, so no annotation is needed, but loop-carried array values, nonlinear arithmetic and the long trial-division loop make discharge depend on careful guard placement.

Position 386 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Store the Motzkin numbers in a 0..41 array of a 64-bit range type, seeding M(0) and M(1) and filling the rest with a for loop using the linear recurrence, with guards before each multiplication and addition. A procedure with a while loop tests each value for primality by trial division up to its square root, and a second for loop prints each number via 'Image with " is a prime" appended when the test succeeds. About 70 lines.

## Proof obligations to watch

- **overflow**: Array elements carried between loop iterations are known only by their 64-bit type range, so each product and sum in the recurrence M(n) = ((2n+1)M(n-1) + (3n-3)M(n-2)) / (n+2) is preceded by an explicit guard that rejects on potential overflow, which never fires for the first 42 values (M(41) is about 1.9e17, well below 2^63).
- **overflow**: The trial-division primality test uses a while loop in a procedure with the condition i <= n / i, so i*i is never computed and i + 1 stays in range because i is bounded by n's type range.
- **division**: The divisor n + 2 is at least 2 by the loop range, and the trial divisor i starts at 2, so both are provably nonzero.
- **termination**: The primality loop, around 4.4e8 iterations in the worst case, must be a while loop inside a procedure (no termination check) because a function would need a variant; the result is passed back through an out Boolean parameter.
- **range**: Image of each number is written into a bounded String buffer sized for 19 digits, with its length guarded before copying so slicing and concatenation stay in bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 42 Motzkin numbers, each marked when prime, to standard output.

Assessed on 2026-10-15 against page revision 414348 of the [task](https://rosettacode.org/wiki/Motzkin_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
