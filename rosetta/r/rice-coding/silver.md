# Rice coding

**Candidate: proofs likely to discharge automatically.** All values are small and bounded by declared subtypes, the only loop-carried values are a guarded position and counter in a procedure, and no function needs a loop variant, so proofs should discharge without annotations.

Position 598 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Fix k=2 and encode each n in 0..10 (embedded) into a record holding a 32-character buffer and a Natural length: q ones, a zero, then two remainder bits computed with / and mod. A procedure decodes by counting leading ones in a while loop guarded by position <= length, then reading the two bits, and the main loop prints n, the code and the decoded value, with an explicit "mismatch" line if they differ. The extra-credit signed variant is left out. About 70 lines.

## Proof obligations to watch

- **index**: Encode writes into a fixed 32-character buffer after a guard that the code length fits, and decode's while loop tests its position against the length before every read.
- **overflow**: The quotient is bounded by the buffer length and the remainder is at most 3, so the decoded value q*4+r stays within a declared range subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and records.

## External effects

- **console output** (allowed): Prints each n, its Rice code and the decoded value, one line per example, via Put_Line.

Assessed on 2026-10-15 against page revision 395244 of the [task](https://rosettacode.org/wiki/Rice_coding) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
