# Dinesman's multiple-dwelling problem

**Candidate: proofs likely to discharge automatically.** All loop variables are Floor-typed for-loop indexes, so differences and abs are bounded by types and every check discharges without invariants, and the loops need no termination variant.

Position 143 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Declare subtype Floor is Integer range 1 .. 5 and five nested for loops over Floor, one per person (Baker, Cooper, Fletcher, Miller, Smith), with the distinct-floor and six constraint tests as one Boolean condition in the innermost body. Each solution is printed with Put_Line using Floor'Image concatenated into short bounded strings; no recursion, no accumulator, no loop-carried state. About 45 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each person's floor for every solution via Put_Line.

Assessed on 2026-10-15 against page revision 415401 of the [task](https://rosettacode.org/wiki/Dinesman's_multiple-dwelling_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
