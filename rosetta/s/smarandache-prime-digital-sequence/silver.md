# Smarandache prime-digital sequence

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by declared subtypes and all loops are for loops over static ranges, so the overflow, range and termination checks follow from types and guards without any annotation. The only extra surface is integer arithmetic, integer division, small functions and integer-to-text output.

Position 890 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A Main procedure loops candidates n over a declared subtype 2 .. 33223 (a bound the task's 100th element 33223 needs) and keeps a count of members found, exiting once it reaches 100. Boolean functions Is_Prime (for-loop trial division by d in 2 .. 182 with a guard d*d <= n) and Digits_Prime (for-loop of 5 iterations taking m mod 10 and m / 10, with a guard that each digit is 2, 3, 5 or 7) classify each candidate, and members with count at most 25 or exactly 100 are printed with Integer'Image. About 50 lines.

## Proof obligations to watch

- **overflow**: The trial-division product d*d stays far below the Integer limit because both the candidate range (up to 33223) and divisor range (up to 182) are declared by subtypes.
- **termination**: Digit stripping uses a for loop over at most 5 iterations with an early exit rather than a while loop, so no variant is needed even if it sits in a function.
- **index**: No array is needed because members are printed as they are found, and the counter is guarded to stay at or below 100.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, procedures, for loops, while loops, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): Prints the first 25 sequence members and the hundredth, one per line.

Assessed on 2026-10-15 against page revision 415189 of the [task](https://rosettacode.org/wiki/Smarandache_prime-digital_sequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
