# Stern-Brocot sequence

**Candidate: proofs plausibly discharge automatically.** Everything is bounded array and for-loop work with a single guarded addition, and the only while loop is in a procedure, so no annotation is needed, but the guard on the sum and the index arithmetic make it depend on program shape.

Position 266 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Fill a 2000-element array of a bounded positive subtype with 1,1 and then, for I in 2..1000, set S(2I-1)=S(I)+S(I-1) and S(2I)=S(I) after a guard on the sum. Print results with Put and scalar 'Image text, find first occurrences of 1..10 and 100 with for loops over the array range and a found flag, and check consecutive-pair GCDs with a procedure using a while loop on bounded positive variables, reporting the outcome by printing text. About 95 lines.

## Proof obligations to watch

- **overflow**: The generation loop sums two array elements whose values are only known by their subtype range, so a guard before each sum rejects the program with a visible outcome if it would exceed the element limit.
- **index**: Writing positions 2*I-1 and 2*I for I in 2..1000 in a 2000-element array follows from the for-loop range, but the prover needs the linear index arithmetic bounded by the declared loop range.
- **range**: Assigning the guarded sum into the bounded element subtype needs the guard to be the exact condition for the subtype, which is routine once written just before the assignment.
- **division**: The Euclid GCD in a procedure uses mod with a divisor guarded by the while condition N /= 0, and loop-carried M and N are typed to a positive range so mod cannot fail.
- **termination**: The GCD and the search loops are while loops inside procedures, which get no termination check, whereas making GCD a function would need a variant Silver cannot supply.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the first fifteen members, the first-occurrence indices for 1 to 10 and for 100, and the GCD check result.

Assessed on 2026-10-15 against page revision 414986 of the [task](https://rosettacode.org/wiki/Stern-Brocot_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
