# Old lady swallowed a fly

**Candidate: proofs likely to discharge automatically.** Fixed embedded text, for loops over a static range 1..8 and case statements over a bounded subtype need no loop-carried values, so every check follows from types and static bounds.

Position 787 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Animals are indexed by a subtype Animal_Index range 1..8 (fly to donkey), with small procedures that use case statements on the index to Put_Line each animal's opening line, its second line, and the "She swallowed the X to catch the Y" line using bounded concatenation of literals. The main body is a for loop over verses whose inner for loop (reverse) walks back down the chain, then the fixed closing "horse" verse is printed; all lyrics are embedded literals, no input is read, and every loop bound is static. About 80 lines.

## Language surface beyond today's Silver

Ranged subtypes, case statements, for loops, procedures and integers.

## External effects

- **console output** (allowed): The lyrics are written line by line with Put_Line.

Assessed on 2026-10-15 against page revision 413817 of the [task](https://rosettacode.org/wiki/Old_lady_swallowed_a_fly) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
