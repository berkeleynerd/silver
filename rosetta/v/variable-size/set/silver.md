# Variable size/Set

**Candidate: proofs likely to discharge automatically.** A static confirming object Size clause is the only new surface this minimal example needs. It is a representation declaration, not a pragma or proof annotation, and does not require a new type, a named subtype, a conversion or a Size attribute expression.

Position 1571 in the [progression](../../../progression.md#stage-38), in stage 38, which adds integer object size clause.

## Approach

Declare an initialized stand-alone object X : Integer := 0 and specify for X'Size use 32 before the null body. Explain that this confirming object representation clause specifies its 32-bit representation on the pinned targets; the task accepts specifying a variable's size and does not require reading the Size attribute or printing it. About 8 lines.

## Language surface recorded by this assessment

Integer object size clause and bounded mutable Integer objects.

Initially assessed on 2026-10-15 against page revision 413114 of the [task](https://rosettacode.org/wiki/Variable_size/Set) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../../assessment-reconciliation-20261025.md).
