# O'Halloran numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from loop-index subtype ranges and one guard before the array write, so no loop invariant is needed; the only cost is about 15 million cheap iterations of the triple loop, which is not a proof issue.

Position 78 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

A Boolean array indexed 8 .. 999 starts all True; three nested for loops over 1 .. 249 (the largest side possible below 1000 since the other two sides are at least 1) compute Area = 2*(L*W + W*H + H*L) and, guarded by Area >= 8 and Area <= 999, clear that entry. A final for loop over the array's range prints each remaining True even index with Put_Line of its 'Image, after a heading line. About 28 lines.

## Proof obligations to watch

- **index**: The array write Areas (Area) is preceded by an explicit if Area <= 999 guard, so the index check discharges from the guard and the array's declared bounds.
- **overflow**: Loop indexes are subtypes limited to 1 .. 249, so every product and sum of three products stays far below Integer'Last without any invariant.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints a heading and the sixteen O'Halloran numbers to standard output.

Assessed on 2026-10-15 against page revision 411924 of the [task](https://rosettacode.org/wiki/O'Halloran_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
