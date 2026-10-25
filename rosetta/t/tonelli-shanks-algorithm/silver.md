# Tonelli-Shanks algorithm

**Candidate: proofs plausibly discharge automatically.** The five required cases fit 64-bit arithmetic when p is limited to below 2**31, and all loops can be bounded for loops or procedure loops, so proofs should discharge with careful range-subtype guards; the 10^50 extra credit would need big numbers and is optional.

Position 626 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Residues are Long_Long_Integer subtypes bounded by 2**31, with a Mul_Mod function and a Pow_Mod procedure that loops over the 63 exponent bits, then a Legendre check, factoring p-1 into q*2^s with a bounded loop, a for-loop search for a non-square z, and the main loop as a for loop of at most s iterations. The five required (n,p) pairs are embedded in a constant array of records; each is guarded (p odd, 3<=p<2**31, n<p, residue test) and prints either the two roots or a specified rejection message. About 130 lines.

## Proof obligations to watch

- **overflow**: Modular products of two residues need a documented limit p below 2**31 held in a ranged subtype so the product fits 64 bits; this covers the five required cases and the 10^9 extra case but not the larger extra-credit ones.
- **range**: Residue values carried through the exponentiation and root-finding loops lose their bounds without invariants, so each mod result is stored into a subtype 0..2**31-1 and guarded by a p>2 and p<2**31 check before use.
- **division**: mod p and division by 2 are safe only after an explicit guard rejecting p below 3, which also gives the specified output for invalid input.
- **termination**: The bit-halving exponent loop and the search for the lowest i are written as procedures with for loops over fixed ranges (63 bits, 1..m-1) so no variant is needed.
- **range**: The exponent 2**(m-i-1) is formed by repeated squaring in a for loop over m-i-1 steps, guarded by i<m, instead of using ** with a computed exponent.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, 'Image of scalars, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each case's n, p and the two roots or a not-a-residue message via Put_Line.

Assessed on 2026-10-15 against page revision 413948 of the [task](https://rosettacode.org/wiki/Tonelli-Shanks_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
