# Chinese remainder theorem

**Candidate: proofs likely to discharge automatically.** All loops are bounded for loops over fixed arrays or ranged subtypes, and the moduli and product are range-limited with an explicit guard, so every check follows from types and guards without an invariant.

Position 134 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Embed n=[3,5,7] and a=[2,3,2] in constrained arrays of ranged subtypes, check pairwise coprimality with a bounded for-loop gcd-free test (searching for a modular inverse by a for loop over 1..n-1 and flagging failure if none is found), and accumulate the sum with a guarded 64-bit accumulator. Print Sum mod Prod using 'Image, or a visible no-solution message when an inverse is missing. About 45 lines.

## Proof obligations to watch

- **overflow**: The running product and the sum of a*s*N/n are loop-carried, so they are held in a 64-bit type with moduli subtyped to 1..1000 and a guard before each multiplication that reports no-solution if the product would exceed a fixed limit.
- **division**: Every divisor and modulus comes from a subtype with a lower bound of 1, so the nonzero check follows from the type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the resulting solution (or a no-solution message) with Put_Line.

Assessed on 2026-10-15 against page revision 414111 of the [task](https://rosettacode.org/wiki/Chinese_remainder_theorem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
