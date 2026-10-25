# Define a primitive data type

**Candidate: proofs likely to discharge automatically.** A distinct integer type with bounded objects and an explanation of compiler checks directly matches the captured Ada answer and task wording. Conversions, arithmetic, loop subtype marks, type Image and bounds attributes are unnecessary for this minimal driver; a named Integer subtype is a different, narrower feature.

Position 1571 in the [progression](../../progression.md#stage-39), in stage 39, which adds static integer types.

## Approach

Declare type One_To_Ten is range 1 .. 10, then initialize A : One_To_Ten := 3 and B : One_To_Ten := A in Main with a null body. Explain that the declaration creates a distinct signed integer type and constrained first subtype, and that initializations and assignments to objects of that first subtype must stay within 1 .. 10 without application-written bounds checks. About 9 lines.

## Language surface recorded by this assessment

Static integer types.

Initially assessed on 2026-10-15 against page revision 412738 of the [task](https://rosettacode.org/wiki/Define_a_primitive_data_type) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
