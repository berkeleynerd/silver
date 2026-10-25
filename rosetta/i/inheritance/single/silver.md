# Inheritance/Single

**Candidate: proofs likely to discharge automatically.** The program only declares types, with null records, no operations and an empty body, so GNATprove has no run-time checks to discharge apart from trivial flow analysis. The only new surface Silver needs is tagged record types and type extension.

Position 1547 in the [progression](../../../progression.md#stage-33), in stage 33, which adds tagged types.

## Approach

Main declares a tagged null record Animal, then extends it to Dog and Cat with null record extensions, and extends Dog to Lab and Collie. The body is a null statement, because the task asks only for the type tree and the declarations themselves show it. There is no data, arithmetic, input or output to guard. About 10 lines.

## Language surface recorded by this assessment

Records and tagged types.

Assessed on 2026-10-15 against page revision 412848 of the [task](https://rosettacode.org/wiki/Inheritance/Single) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
