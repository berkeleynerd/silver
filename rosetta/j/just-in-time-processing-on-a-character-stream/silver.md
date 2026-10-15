# Just in time processing on a character stream

**Candidate: proofs likely to discharge automatically.** Everything is a single pass over an embedded constant string with small bounded counters and a bounded output buffer, so no annotation is needed. The generalized separator and selection-function extras are optional and omitted.

Position 780 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed a constant text (pages, lines, tab-fields separated by formfeed, linefeed and tab characters, with "Silence-Dogood." hidden at the diagonal positions) and a bounded Character output buffer. A for loop over the text's index range tracks bounded page, line, field and position counters, resetting the inner ones at each separator. When all four counters equal the current target i, the character is emitted, a "!" stops processing, and i advances; the buffer is then printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: Page, line, field and position counters are loop-carried but are range-typed and incremented only after a guard against their upper bound, so the checks discharge.
- **index**: Each text index comes from a for loop over the embedded text's own range and the output buffer is indexed only after a guard on its capacity, so the checks discharge.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, records, string indexing, string building, for loops, case statements, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the decoded password.

Assessed on 2026-10-15 against page revision 369834 of the [task](https://rosettacode.org/wiki/Just_in_time_processing_on_a_character_stream) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
