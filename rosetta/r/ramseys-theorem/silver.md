# Ramsey's theorem

**Candidate: proofs likely to discharge automatically.** Everything is fixed-size array work with static loop bounds and a small modulus, so index and range checks follow from the declared subtypes, and the only loop-carried value is a Boolean flag.

Position 662 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the Paley graph on 17 nodes (nodes adjacent when their difference is a quadratic residue mod 17) as a 17 by 17 Boolean matrix filled by two nested for loops using a constant Boolean residue table indexed by (i - j + 17) mod 17. Four nested for loops over a<b<c<d (2380 subsets) check whether all six edges among the four nodes are equal, setting a Boolean Found flag, and the program prints each matrix row as a 17-character String of '0' and '1' followed by either a satisfied or violated message. All loop bounds are static subtype ranges so no invariants are needed. About 55 lines.

## Proof obligations to watch

- **index**: The edge test indexes a residue table with (i - j + 17) mod 17, which the prover bounds to 0..16 from the declared index subtypes, and the matrix and row-string indexes are for-loop variables over their own ranges.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing and for loops.

## External effects

- **console output** (allowed): Prints the 17 by 17 adjacency matrix and the verdict line with Put_Line.

Assessed on 2026-10-15 against page revision 414427 of the [task](https://rosettacode.org/wiki/Ramsey's_theorem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
