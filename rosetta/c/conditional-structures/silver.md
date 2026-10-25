# Conditional structures

**Candidate: proofs likely to discharge automatically.** The program only branches on a constant of an enumeration type and prints literal strings, so it has no run-time check that could fail beyond what types and static case coverage already settle. The task's "select" demonstration needs tasking, which the task does not require, so it is left out.

Position 1153 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Main declares an enumeration type Day and an embedded example constant Today, then shows each conditional structure Ada/SPARK offers in turn: an if/elsif/else chain, a case statement with an alternation choice and a when others default, a full-coverage case statement without others, an if expression and a case expression. Each one passes a String literal to Put_Line. No arithmetic, indexing or loops are involved, so the only checks are the trivial ones on discrete choices that the compiler has already shown to be complete. About 45 lines.

## Language surface recorded by this assessment

Enumerations, case statements and conditional expressions.

## External effects

- **console output** (allowed): Each conditional structure reports which branch it took with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414613 of the [task](https://rosettacode.org/wiki/Conditional_structures) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
