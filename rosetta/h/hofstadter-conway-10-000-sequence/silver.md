# Hofstadter-Conway \$10,000 sequence

**Candidate: proofs plausibly discharge automatically.** Every check is a bounded array index, range or 64-bit arithmetic check that a guard placed just before the operation discharges, with no loop-carried fact needing an invariant, so only the guards' shape makes it plausible rather than likely.

Position 933 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Store the sequence in a constrained array of 1..2^20 with element subtype 1..2^20, fill it with a for loop from 3 using guards that S(K-1) < K and the sum stays within range, otherwise Reject. For each power-of-two block, track the best ratio by integer cross-multiplication in a 64-bit range type and print the integer-scaled 8-digit decimal with the position via string building from 'Image, then scan backward from the last block above 0.55 (compared as a*100 > 55*n) for the Mallows number. All floating point is replaced by scaled integers and all output goes through Put_Line in the Main procedure. About 110 lines.

## Proof obligations to watch

- **index**: S(S(K-1)) is always in range because the element subtype is 1..2^20, and K-S(K-1) is guarded by an explicit check that S(K-1) < K with Reject as the visible outcome otherwise.
- **range**: The sum of two elements can exceed the element subtype, so it is computed in a wider type and a guard rejects results above 2^20 before storing, as the loop carries only the array element type.
- **overflow**: Ratio comparison a(k)*n versus a(n)*k and the 8-digit scaling a*10^8 are done in a 64-bit range type where operands bounded by 2^21 make products fit.
- **termination**: The backward Mallows search and the table loops use for loops (or a while loop in a procedure) so no termination check applies.
- **stack**: A 2^20-element array is about 4 MB of static or stack storage, which GNATprove does not check and is an environmental premise.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the maxima table and the Mallows number with Put_Line.

Assessed on 2026-10-15 against page revision 413744 of the [task](https://rosettacode.org/wiki/Hofstadter-Conway_%2410,000_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
