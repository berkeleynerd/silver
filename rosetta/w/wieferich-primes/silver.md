# Wieferich primes

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every operand is bounded by declared subtypes (N below 5000, residue below 25 million), so the overflow, range and division checks follow from types and loop bounds with no invariant needed.

Position 759 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The Main procedure loops N over 2 .. 4999, tests primality with a nested for loop over D in 2 .. 70 that sets a Boolean flag when D*D <= N and N mod D = 0, and for primes computes 2^(N-1) mod N*N by repeated doubling in a for loop with a subtype-bounded accumulator. Each prime whose residue equals 1 is printed with Put_Line of its Integer'Image, after a header line. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried residue Q is declared in a subtype 0 .. 25_000_000 and the modulus is a variable at most 4999*4999, so 2*Q stays within Integer and the mod result is provably below the modulus.
- **division**: The modulus N*N is only used after the loop index N is known to be at least 2, so mod by zero is excluded by the loop range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars and case statements.

## External effects

- **console output** (allowed): Prints a header line and each Wieferich prime below 5000 with Put_Line.

Assessed on 2026-10-15 against page revision 411994 of the [task](https://rosettacode.org/wiki/Wieferich_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
