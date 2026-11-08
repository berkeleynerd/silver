# Move-to-front algorithm

**Candidate: proofs likely to discharge automatically.** All loops are for loops over bounded ranges and every index comes from a 0..25 subtype or a loop variable, so the checks follow from types and loop ranges without invariants. The recursion in the existing solution is replaced by iteration and everything sits in procedures.

Position 529 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

One procedure Encode_Check(S) with fixed-capacity arrays: a 26-element Character symbol table, an array of 0..25 indices, and a decoded character buffer. Encoding finds the symbol with a for loop over the table, then shifts earlier entries right with a for reverse loop and puts the symbol at the front; decoding indexes the table by each stored index and does the same move. The program compares the decoded buffer to the original, prints the indices with Integer'Image through Put, and prints Correct or WRONG for each of the three embedded strings. About 75 lines.

## Proof obligations to watch

- **index**: The symbol-table search is a for loop over the table's own range and the shift loops run over ranges within 0..25, so every index is bounded by types and loop ranges.
- **range**: The found position is stored in a subtype 0..25 assigned only inside the loop at the matching index, and an explicit Found flag rejects any symbol outside a..z with a visible message.
- **length**: Input, output and decoded buffers use a fixed capacity (e.g. 16) with an explicit length, and each embedded string is checked against that capacity before copying.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, for loops, while loops, procedures, string indexing, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints each string, its encoded indices and the round-trip check result.

Assessed on 2026-10-15 against page revision 414349 of the [task](https://rosettacode.org/wiki/Move-to-front_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
