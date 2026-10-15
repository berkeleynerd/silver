# Useless instructions

**Candidate: proofs likely to discharge automatically.** The task only asks to showcase a redundant language feature, which fits entirely inside today's Silver surface with no loops or arithmetic, so every check is trivial and nothing needs an annotation.

Position 27 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program names a redundant built-in (elsif, which nested else-if statements make redundant) and demonstrates it with a String constant selector classified once by an if/elsif chain and once by nested if/else, printing both results and a line stating they are identical. Everything uses existing Silver constructs (String constants, equality tests, if/elsif/else, Put_Line), with no loops, arithmetic or input. About 25 lines.

## External effects

- **console output** (allowed): The program prints its demonstration and explanation lines with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 409976 of the [task](https://rosettacode.org/wiki/Useless_instructions) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
