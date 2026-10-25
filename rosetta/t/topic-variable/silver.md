# Topic variable

**Candidate: proofs likely to discharge automatically.** Unlike an ordinary variable named It, @ has predefined language meaning that abbreviates the current target; the task's optional square/root example is unnecessary. This is a future explicit Silver admission of inherited Ada syntax, with negation safe over symmetric bounded ranges and no need for scalar guard refinement.

Position 1574 in the [progression](../../progression.md#stage-41), in stage 41, which adds assignment target name.

## Approach

Demonstrate Ada 2022's target-name symbol @ as the limited current-object analogue: initialize two Integer objects with symmetric ranges, assign A := (-@) and B := (-@), and print their results. Explain that @ is a constant view of the current assignment target, is permitted only in that assignment's right-hand expression, and has no persistent or dynamically nested topic binding. About 15 lines.

## Language surface recorded by this assessment

Assignment target name, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): Displays the values obtained when @ denotes two different assignment targets and explains its assignment-local scope.

Initially assessed on 2026-10-15 against page revision 405498 of the [task](https://rosettacode.org/wiki/Topic_variable) by claude-sonnet-5-5 at medium effort; current confidence medium. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-25 by Codex through targeted source review; see the [review record](../../assessment-reconciliation-20261025.md).
