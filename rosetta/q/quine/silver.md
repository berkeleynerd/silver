# Quine

**Candidate: proofs likely to discharge automatically.** A quine needs only constant strings, a quote character built from its code and bounded concatenation, so every check follows from static lengths and nothing requires an annotation or dynamic behavior. Self-reference is by construction rather than by reading files, so no Oracle rule is violated.

Position 424 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The source is split into a few String constants holding the program text before, between and after the quoted data, plus a Character constant Q built from Character'Val (34) so no escaped quotes are needed. The main body is one Put_Line of a concatenation that interleaves the constants with Q, reproducing the program text exactly, with no loops, input or guards. About 15 lines.

## Proof obligations to watch

- **length**: The concatenation result has a static length derived from constant String pieces, so the length check on the Put_Line argument discharges from literal lengths.

## Language surface recorded by this assessment

Characters.

## External effects

- **console output** (allowed): The program prints its own source text with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415317 of the [task](https://rosettacode.org/wiki/Quine) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
