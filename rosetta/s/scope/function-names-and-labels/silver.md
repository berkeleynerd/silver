# Scope/Function names and labels

**Candidate: proofs likely to discharge automatically.** Every check in the program follows from string literals, static for-loop ranges and calls without arithmetic on loop-carried values, so the proofs should discharge without annotations, and the task allows explaining goto labels instead of using them.

Position 1461 in the [progression](../../../progression.md#stage-27), in stage 27.

## Approach

A library package declares a public function in its spec and keeps a helper procedure visible only in its body, while Main contains a nested procedure that can be called only within Main, and each call prints a line saying where that name is visible. To demonstrate labels, two named nested for loops over small static ranges use `exit Outer when` to leave the outer loop from inside the inner one, with printed lines explaining that this name is visible only inside its own loop. A printed note explains that goto statement labels are absent because Silver has not established admission and control-flow composition rules for goto, although SPARK 16.1 permits forward goto. About 70 lines.

## Language surface recorded by this assessment

Integers, for loops, while loops, procedures, functions and packages.

## External effects

- **console output** (allowed): The program prints lines that explain and trace each visibility level as the demonstration runs.

Initially assessed on 2026-10-15 against page revision 413328 of the [task](https://rosettacode.org/wiki/Scope/Function_names_and_labels) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../../review-343c2f8.md).
