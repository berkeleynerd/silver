# Boustrophedon transform

**Candidate: proofs plausibly discharge automatically.** Every check is a bounded-range array index or a guarded addition in for loops, so nothing needs an annotation, but the loop-carried triangle sums depend on careful bound guards and the 2D array and text formatting are beyond today's Silver.

Position 718 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Keep a 15-element sequence array of a bounded integer subtype and a 15x15 triangle array, and a procedure fills T(k,0)=a(k) then for k in 1..14 and n in 1..k sets T(k,n) from the recurrence after a bound guard, with b(n)=T(n,n). The six sequences (ones, all 1s, alternating, primes, Fibonacci, factorials) are built by short for loops or embedded as constant aggregates, and each result is formatted with 'Image into a bounded line buffer and printed with Put_Line. The 1000-digit stretch is omitted as optional. About 110 lines.

## Proof obligations to watch

- **overflow**: Each triangle sum T(k,n-1)+T(k-1,k-n) is a loop-carried value, so the program stores values in a bounded subtype (about 10**15) and guards each addition with a visible reject when the sum would exceed the bound, which keeps the true results (max about 3e11) in range.
- **index**: The index k-n is within 0..k-1 because the for loops run n in 1..k and k in 1..14 over the array's own bounds, which provers discharge from the loop ranges.
- **range**: Generating factorial inputs by multiplication needs a guard before each product (or the factorial sequence is embedded as constants) so that the loop-carried accumulator stays within the subtype.
- **length**: Each output line is built in a fixed-size buffer sized for 15 numbers of up to 20 characters, with an explicit guard before each append.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 15 transformed values for each of the six sequences as text lines.

Assessed on 2026-10-15 against page revision 415272 of the [task](https://rosettacode.org/wiki/Boustrophedon_transform) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
