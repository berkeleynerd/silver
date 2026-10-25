# Sealed classes and methods

**Candidate: proofs likely to discharge automatically.** The task allows describing an equivalent structure when inheritance is unavailable, and Silver already supports Put_Line with string literals, so there are no checks to prove beyond what Silver already discharges.

Position 18 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The task only asks for an explanation (with an example if possible), so the program is a Main procedure with SPARK_Mode (On) that emits a handful of fixed Silver_IO.Put_Line lines. The lines say that Silver has no inheritance, so every type is effectively sealed, and that a non-tagged or private type is how Ada simulates a final class. There is no data, loop or guard. About 12 lines.

## External effects

- **console output** (allowed): The program prints a short explanation of how Ada/SPARK simulates sealed classes and methods.

Assessed on 2026-10-15 against page revision 413221 of the [task](https://rosettacode.org/wiki/Sealed_classes_and_methods) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
