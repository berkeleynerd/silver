# Find Chess960 starting position identifier

**Candidate: proofs likely to discharge automatically.** Every operation is small bounded integer arithmetic over an 8-character string with for loops, and all counters are ranged subtypes with explicit guards, so no annotation is needed and invalid arrays get a visible rejection.

Position 788 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the four example arrays (QNRBBNKR, RNBQKBNR, RQNBBKRN, RNQBBKRN) as 8-character constants and pass each to a procedure that scans it once with a for loop, counting each piece letter with guarded small ranged counters and recording positions in tiny arrays, and any wrong count or illegal letter prints a specified rejection line. It then validates the king lies between the rooks and the bishops sit on opposite colours, computes the knight combination number from the knights' ranks among the five non-queen non-bishop squares via a small case or if table, the queen's rank among six squares, and the dark and light bishop indices by integer division by 2, and prints 96N+16Q+4D+L using integer image. About 110 lines.

## Proof obligations to watch

- **range**: The per-piece position counters and rank values are loop-carried, so each is declared with a small ranged subtype and incremented only under an explicit guard (for example count below 2), with an overflow-free final 96N+16Q+4D+L bounded by 0..959.
- **index**: Position arrays are indexed by counters that are guarded before each store, and the 8-character input is indexed by a for loop over its own range, so no index check depends on an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, 'Image of scalars, for loops, procedures, functions, Boolean objects and case statements.

## External effects

- **console output** (allowed): Prints each embedded starting array with its SP-ID or a rejection message.

Assessed on 2026-10-15 against page revision 413987 of the [task](https://rosettacode.org/wiki/Find_Chess960_starting_position_identifier) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
