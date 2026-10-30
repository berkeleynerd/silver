# Miller-Rabin primality test

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges below 2**31 and every loop can be a for loop or sit in a procedure, so checks follow from types and guards, but careful range shaping of loop-carried residues and text parsing make it plausible rather than likely.

Position 1178 in the [progression](../../progression.md#stage-19), in stage 19.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Restrict n to a declared range 0 .. 2**31-1 so residue products fit in Long_Long_Integer, with Mod_Exp as a procedure using a fixed 32-iteration for loop over exponent bits with square-and-multiply on bounded residues. The test handles n < 4 and even n by guard, factors n-1 into 2^s*d with a bounded for loop and exit, then runs K rounds with bases drawn from a small deterministic LCG reduced into 2..n-2, with an inner for loop of s-1 squarings and exit when x = n-1. Main parses the first argument with validation, rejects bad input, and prints the primes up to 1000 plus the verdict for the argument. About 110 lines.

## Proof obligations to watch

- **overflow**: Modular products are discharged by restricting n to a declared range below 2**31 so every product of two residues fits in 64 bits, which is a documented resource limit.
- **termination**: Modular exponentiation and the factoring of n-1 are written as for loops with exit (a fixed bit count of 32) inside procedures, so no variant is needed.
- **overflow**: The power-of-two counter s and the loop-carried residues stay within declared subtypes, with an explicit guard before incrementing s, since no invariant can bound them.
- **range**: The pseudo-random base is reduced with mod into 2..n-2 after guarding n > 3, and the generator state is kept bounded by a small LCG reduced with mod.
- **other**: A deterministic generator with a fixed round count is a faithful reading of the randomized test, and text parsing must validate digits and range so invalid input is rejected.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, enumerations, arrays, for loops, while loops, procedures, functions, text parsing, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each tested number and its composite or probably-prime verdict.
- **arguments** (allowed): The number to test is taken from the first command-line argument.
- **exit status** (allowed): Invalid or out-of-range input is rejected with a specified failure status.

Assessed on 2026-10-15 against page revision 413786 of the [task](https://rosettacode.org/wiki/Miller-Rabin_primality_test) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
