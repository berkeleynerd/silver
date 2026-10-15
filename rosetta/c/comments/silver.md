# Comments

**Candidate: proofs likely to discharge automatically.** Ada's only comment form is the "--" line comment, which is ordinary lexical source that is not an annotation or pragma, so the program is a straight-line Put_Line with no proof obligations.

Position 6 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with pragma SPARK_Mode (On) contains line comments beginning with "--", including a full-line comment, a trailing comment and a commented-out statement. It prints one constant String line through Silver_IO.Put_Line, with no loops, arithmetic or inputs. About 8 lines.

## External effects

- **console output** (allowed): The program prints a short line stating that Ada has one comment form, introduced by two hyphens.

Assessed on 2026-10-15 against page revision 414123 of the [task](https://rosettacode.org/wiki/Comments) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
