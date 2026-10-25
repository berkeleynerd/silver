# Convert CSV records to TSV

**Candidate: proofs plausibly discharge automatically.** The task is pure string scanning with character-level rules and no conflicts, and every index and buffer length is guarded just before use, though several loop-carried positions need careful guards because there are no invariants.

Position 1136 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The program embeds the thirteen test records as String constants (building the TAB, CR and NUL ones by concatenating Character'Val values) and passes each to a Convert procedure that scans it with a Pos index in a state-machine loop (skip spaces, quoted field with doubled-quote handling, or unquoted field up to a comma, stopping at nonsense). Each output character goes through an Append procedure that guards the fixed-capacity buffer and applies the escape rules (TAB to \t, LF to \n, CR to \r, NUL to \0, backslash doubled before n, r or t), after which the record is printed as input => output via a buffer slice. Over-long input is rejected with a printed message rather than truncated. About 150 lines.

## Proof obligations to watch

- **index**: Every read of Line(Pos) and write of Buf(Len) is immediately preceded by an explicit bound guard on the loop-carried Pos or Len, so the check does not depend on an invariant.
- **length**: The output buffer is fixed-capacity, and a guard before each append (up to two characters) sets an overflow flag that ends the record with a visible rejection message instead of silently truncating.
- **overflow**: Pos+1 and Len+2 on loop-carried Integer values need guards (Pos < Line'Last, Len <= Capacity-2) or ranged subtypes so the increments cannot overflow.
- **termination**: The field-scanning while loops live in a procedure, which gets no termination check, and each iteration advances Pos.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, unconstrained arrays, for loops, while loops, procedures and text parsing.

## External effects

- **console output** (allowed): Each embedded test record and its TSV conversion is printed with Put_Line.

Assessed on 2026-10-15 against page revision 387291 of the [task](https://rosettacode.org/wiki/Convert_CSV_records_to_TSV) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
