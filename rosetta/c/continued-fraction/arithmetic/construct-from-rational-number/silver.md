# Continued fraction/Arithmetic/Construct from rational number

**Candidate: proofs likely to discharge automatically.** Every check follows from declared integer ranges and the while M2 /= 0 guard immediately before mod and division, and there is no recursion, function loop or annotation need, so proofs should discharge. The remaining effort is Silver surface (integers, ranged types, arrays, loops, Put and 'Image) rather than proof difficulty.

Position 598 in the [progression](../../../../progression.md#stage-11), in stage 11.

## Approach

Embed the 18 numerator/denominator pairs in a constant array of records with a declared integer range wide enough for them, and loop over it with a for loop. A procedure copies each pair into two range-typed variables and runs a while loop, which is allowed in a procedure, that divides while the denominator is nonzero. It prints the terms with Put and 'Image, using a separator that depends on the term position. About 70 lines.

## Proof obligations to watch

- **overflow**: The expression (N1 - r) / N2 is discharged because both operands are bounded by a declared 64-bit subtype range of about plus or minus 10**9, so no overflow or range check on the quotient can fail.
- **division**: mod and / are discharged by the while M2 /= 0 loop condition, which holds just before each division.
- **range**: Loop-carried M1 and M2 are assigned only values within their declared subtype range (the remainder lies within the bounds of the divisor's range), so the type alone covers them after the first iteration.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, records, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each fraction and its continued fraction terms to standard output.

Assessed on 2026-10-15 against page revision 413673 of the [task](https://rosettacode.org/wiki/Continued_fraction/Arithmetic/Construct_from_rational_number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
