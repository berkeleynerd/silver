# Faulhaber's triangle

**Candidate: proofs plausibly discharge automatically.** Every value in the triangle fits in bounded integer subtypes and only the final 53-digit sum needs a fixed-capacity big number, so all checks follow from type ranges and explicit guards without annotations, though loop-carried rational and carry arithmetic needs careful shape.

Position 1401 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Store the 18-row triangle as two 2-D arrays (numerator, denominator) of bounded integer subtypes, filling each row by the recurrence a(i,j)=a(i-1,j-1)*i/j and a(i,1)=1-sum, reducing with a gcd procedure; print the first 10 rows with fixed-width string building. For the extra credit, scale row 17 to a common denominator, accumulate numerator*1000^j in a fixed-capacity base-10^k digit array via multiply-by-small and add, divide by the common denominator with a small remainder, and print the digits. About 230 lines.

## Proof obligations to watch

- **overflow**: Each row entry is a fraction with bounded numerator and denominator, and the row recurrence multiplies i by the numerator and j by the denominator, so range-bounded subtypes plus an explicit guard that prints a visible failure message are needed before each product.
- **termination**: The gcd reduction needs a while loop, which is placed in a procedure (no termination check) rather than in a function.
- **overflow**: The 53-digit sum needs a fixed-capacity digit array whose carry values are bounded by the digit-base subtype, with a capacity guard before each carry-out, so the loop-carried carries must stay within type ranges.
- **index**: Triangle entries a(i,j) with j up to i+1 and digit positions during big-number multiply and divide are indexed by loop-carried values, which discharge through for-loops over the arrays' own ranges or guards before each access.
- **range**: Rational terms with negative numerators require the big-number sum to handle sign, done by accumulating positive and negative terms separately and subtracting after a comparison guard.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, procedures, functions, big numbers, string building, 'Image of scalars, Put without a newline, Boolean objects and conditional expressions.

## External effects

- **console output** (allowed): Prints the first 10 triangle rows and the 53-digit sum to standard output.

Assessed on 2026-10-15 against page revision 412788 of the [task](https://rosettacode.org/wiki/Faulhaber's_triangle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
