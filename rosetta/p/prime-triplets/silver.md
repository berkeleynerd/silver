# Prime triplets

**Candidate: proofs likely to discharge automatically.** Primality by trial division over static ranges in for loops needs no loop-carried facts, so all range, overflow and division checks follow from subtype bounds and the loop index guards.

Position 882 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A subtype P_Range is 2..5510 and a Boolean function Is_Prime(N : P_Range) loops d in 2..80 with a flag-free test (if d*d < N+1 and N mod d = 0 then return False), then returns N >= 2. Main loops p in 3..5499, tests Is_Prime(p), Is_Prime(p+2), Is_Prime(p+6) with and then, and for each triple prints one line of the three Integer'Image values via Put_Line (or Put plus a final Put_Line). All data is embedded and the bounds are static, so no loop-carried value needs an invariant. About 35 lines.

## Proof obligations to watch

- **overflow**: All values stay below 5510 and the divisor test d*d is bounded by a subtype 2..80, so every arithmetic check follows from declared ranges.
- **termination**: Only for loops are used (primality by trial division over a fixed divisor range, no while loops or recursion), so the function termination check is trivial.
- **length**: Each output line is built from three Integer'Image values concatenated into a bounded buffer sized for the 42 triples, which needs a sized-string guard or per-triple Put_Line to keep lengths provable.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, functions, procedures, for loops, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints each prime triple (p, p+2, p+6) with p < 5500 to standard output.

Assessed on 2026-10-15 against page revision 403933 of the [task](https://rosettacode.org/wiki/Prime_triplets) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
