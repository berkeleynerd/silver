# Riordan numbers

**Candidate: proofs plausibly discharge automatically.** The first 32 terms peak near 1.3e12, so a 64-bit ranged type with a pre-store guard lets every overflow, range and division check discharge without annotations, with only the loop-carried recurrence needing careful shape.

Position 164 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Store a(0..31) in a constrained array of a 64-bit-range subtype, fill a(0)=1 and a(1)=0, then loop i in 2..31 computing the recurrence in a wide intermediate and guarding the result against the element bound before storing. A second for loop prints each term with Put_Line of a label concatenated with its 'Image text; the optional digit-count stretch (which needs big numbers) is left out. About 35 lines.

## Proof obligations to watch

- **overflow**: The recurrence term (n-1)*(2*a(n-1)+3*a(n-2)) is computed in a 64-bit range type, and because the values are loop-carried with no invariant, the prover knows only the element subtype range, which is chosen small enough that 30*5*bound cannot overflow.
- **range**: The quotient stored back into the array is not provably within the element subtype, so an explicit guard before the store rejects with a visible outcome if it would exceed the bound, which the first 32 terms never reach.
- **division**: The divisor i+1 is at least 3 for every loop index, which follows directly from the for-loop range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the 32 Riordan numbers, one per line, with Put_Line.

Assessed on 2026-10-15 against page revision 414445 of the [task](https://rosettacode.org/wiki/Riordan_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
