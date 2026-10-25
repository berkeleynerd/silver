# Unicode variable names

**Candidate: proofs likely to discharge automatically.** Unicode identifiers are permitted by inherited Ada/SPARK but excluded by today's Silver ASCII source rule, and today's scalar analysis also cannot justify this increment. Explicit Unicode identifier support and scalar guard refinement are future surface, not Oracle amendments or currently delivered capabilities.

Position 1576 in the [progression](../../progression.md#stage-43), in stage 43, which adds scalar guard refinement and unicode identifiers.

## Approach

Declare Δ : Integer range 1 .. 2 := 1, increment it with Δ := (Δ + 1) inside if Δ < 2 then, and print Integer'Image (Δ). Accompany the source with the admitted encoding and Unicode identifier documentation; the guard makes the increment fit its range once scalar guard refinement is admitted. About 12 lines.

## Language surface recorded by this assessment

Unicode identifiers, scalar guard refinement, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): Prints the incremented value of the object whose identifier contains the Unicode delta character.

Initially assessed on 2026-10-15 against page revision 413955 of the [task](https://rosettacode.org/wiki/Unicode_variable_names) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
