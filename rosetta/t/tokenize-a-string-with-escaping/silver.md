# Tokenize a string with escaping

**Candidate: proofs likely to discharge automatically.** All checks follow from for-loop indexes over the input's own range and explicit capacity guards before each buffer or table write, with no recursion, no while loops and no annotations needed. The main work is the string-building and indexing library surface, not hard proofs.

Position 608 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The input is an embedded constant String, and a single for loop over its own index range scans the characters with an Escaped Boolean, appending non-special characters into a fixed-capacity Character buffer and recording field start/end offsets in a fixed-size table. On a separator, the current field is closed (guarded by a field-count limit), and after the loop the last field is closed; an explicit guard rejects with a visible message when the buffer or field table would overflow. A procedure then prints each field wrapped in quotes using Put and Put_Line. About 70 lines.

## Proof obligations to watch

- **index**: Output buffer writes and field-table writes are each guarded by explicit capacity checks before use, with overflow rejected visibly.
- **range**: Loop-carried length and field counters are declared with bounded ranges and guarded before increment so no range check can fail.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures, Put without a newline, records and Boolean objects.

## External effects

- **console output** (allowed): Prints each resulting field on its own line so the fields are easy to see.

Assessed on 2026-10-15 against page revision 411937 of the [task](https://rosettacode.org/wiki/Tokenize_a_string_with_escaping) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
