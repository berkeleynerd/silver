# Unicode variable names

**Candidate: proofs likely to discharge automatically.** The bare-name/static-threshold increment fits the prepared scalar-guard-refinement fragment; its complete validation remains pending. Unicode identifiers are permitted by inherited Ada/SPARK but remain excluded by Silver ASCII source rules, so this task still requires explicit Unicode identifier support. No Unicode admission or task delivery is claimed.

Position 1574 in the [progression](../../progression.md#stage-42), in stage 42, which adds unicode identifiers.

## Approach

Declare Δ : Integer range 1 .. 2 := 1, increment it with Δ := (Δ + 1) inside if Δ < 2 then, and print Integer'Image (Δ). Accompany the source with the admitted encoding and Unicode identifier documentation; the guard makes the increment fit its range once scalar guard refinement is admitted. About 12 lines.

## Language surface recorded by this assessment

Unicode identifiers, scalar guard refinement, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): Prints the incremented value of the object whose identifier contains the Unicode delta character.

Initially assessed on 2026-10-15 against page revision 413955 of the [task](https://rosettacode.org/wiki/Unicode_variable_names) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
