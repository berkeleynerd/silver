# Strip control codes and extended characters from a string

**Candidate: proofs plausibly discharge automatically.** Everything is bounded character-by-character filtering in a for loop, so checks follow from types and one guard on the loop-carried count, with no recursion or annotations needed (the Ada solution's recursive function would be replaced by iteration).

Position 551 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed the sample as a constant String built from literals and Character'Val codes, then run one for loop over its range testing each Character against the printable range 32..126 (control codes stripped) and against above-127 (extended kept in the first output only). Characters are appended to fixed-size String buffers with a ranged Natural count, guarded before each increment, and the slices Buffer(1 .. Count) are printed with Put_Line. About 45 lines.

## Proof obligations to watch

- **range**: The output count is a loop-carried value, so each increment must sit behind an explicit guard that the buffer has room, with a visible rejection otherwise.
- **index**: Writing Out(Count) after the guarded increment discharges because Count is declared in 0 .. buffer length and the guard bounds it just before use.
- **initialization**: The output buffers must be fully initialized (for example with spaces) before slices are printed, which a declaration initializer provides.

## Language surface beyond today's Silver

Characters, string indexing, string building, for loops, integers, ranged subtypes and procedures.

## External effects

- **console output** (allowed): Prints the original string and the two filtered strings with Put_Line.

Assessed on 2026-10-15 against page revision 414523 of the [task](https://rosettacode.org/wiki/Strip_control_codes_and_extended_characters_from_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
