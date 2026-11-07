# Longest common substring

**Candidate: proofs plausibly discharge automatically.** All indexing follows from for-loop ranges and while-condition guards, but the loop-carried best length/start and match counter need careful guards since no invariants exist, so discharge depends on program shape. No annotation, recursion or non-trivial arithmetic is required.

Position 543 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the two strings as constant String(1..11) and String(1..16); a procedure Longest_Common uses nested for loops over every start pair (I, J) and an inner while loop that extends match length K under guards K < 11, I+K <= 11, J+K <= 16 and character equality, updating Best_Len and Best_Start (ranged subtypes) when K exceeds Best_Len. It then copies the best substring into a fixed 11-character buffer behind a guard on Start+Len-1 <= 11 and prints the slice (buffer(1..Best_Len)) with Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: Indexes Left(I+K) and Right(J+K) are discharged by guards in the while condition (I+K <= Left'Last and J+K <= Right'Last) placed just before use.
- **range**: The loop-carried match length K and best length/start are bounded only by their subtype ranges, so each increment and slice bound needs an explicit guard (K < 11 before K+1; Start+Len-1 <= 11 before slicing or copying) that GNATprove cannot derive without an invariant.
- **overflow**: Indices and lengths use small ranged subtypes so sums like I+K stay far below Integer'Last, discharged by types alone.
- **termination**: The inner while loop sits in a procedure (no termination check) and the function-style wrapper is avoided in favor of a procedure with out parameters.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints the longest common substring "test" with Put_Line.

Assessed on 2026-10-15 against page revision 411863 of the [task](https://rosettacode.org/wiki/Longest_common_substring) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
