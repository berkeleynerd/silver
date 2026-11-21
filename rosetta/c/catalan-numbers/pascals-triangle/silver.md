# Catalan numbers/Pascal's triangle

**Candidate: proofs plausibly discharge automatically.** All values stay below 2**31 and every index comes from for-loop ranges, so only the loop-carried row additions need explicit overflow guards, which makes discharge plausible rather than trivially likely.

Position 1362 in the [progression](../../../progression.md#stage-23), in stage 23.

## Approach

Keep one Pascal row as an array of Natural indexed 0..30, initialised to row 0, and update it in place with a reverse for loop for each of the 30 rows, guarding every addition against overflow with a Reject outcome. After building row 2n, the n-th Catalan number is Row(n) - Row(n+1), printed with Integer'Image through Put_Line, for n from 1 to 15 (Catalan numbers C(n) from rows 2n requires snapshotting at each even row inside a single loop). About 35 lines.

## Proof obligations to watch

- **overflow**: Pascal row entries are loop-carried values whose sum has no invariant bound, so each addition is guarded by a comparison against Integer'Last that leads to Reject, and the true values (at most 155117520) never trigger it.
- **index**: Row indexes and the Catalan extraction indexes come from for-loop ranges over the array's own bounds, so they discharge routinely.
- **range**: Element subtype Natural makes the subtraction of adjacent central entries safe, though the prover must see that both operands are non-negative from the type alone.
- **length**: Integer'Image results are bounded by the type, so appending them to a fixed-size line buffer or printing directly is routine.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, string building, procedures and exit status.

## External effects

- **console output** (allowed): Prints the 15 Catalan numbers, one per line, via Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415356 of the [task](https://rosettacode.org/wiki/Catalan_numbers/Pascal's_triangle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
