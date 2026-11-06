# Enforced immutability

**Candidate: proofs likely to discharge automatically.** Current constant String and Integer declarations prevent assignments to those objects, and finite-loop indexes are also immutable. An independently mutable Integer copy demonstrates that changing another object does not modify the constant; no new language construct is needed.

Position 33 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares Answer : constant Integer := 42, Name : constant String := "Silver" and mutable Copy : Integer := Answer. It prints the constants, assigns Copy := 43 and prints Copy alongside the unchanged Answer. A one-iteration loop prints its immutable index. Commented invalid assignments document that constants and indexes cannot be targets; the comments themselves are not executable negative-test evidence. Existing declaration and assignment membership rules provide the enforcement. About 17 lines.

## Language surface recorded by this assessment

Immutable Integer arithmetic, bounded mutable Integer objects, Integer range for loops and Integer image.

## External effects

- **console output** (allowed): The program prints the values of its constants with Silver_IO.Put_Line to show they were created and remain unchanged.

Initially assessed on 2026-10-15 against page revision 414182 of the [task](https://rosettacode.org/wiki/Enforced_immutability) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
