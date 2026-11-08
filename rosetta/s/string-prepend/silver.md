# String prepend

**Candidate: proofs likely to discharge automatically.** The task is one prepend and one print on embedded literal data, so every length and index check follows from constants and a single guard before the copy. Silver already has bounded concatenation, so only a buffer with a computed length and slice printing are missing.

Position 87 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Keep the variable as a fixed-capacity buffer (a String of capacity 32 plus a length in a declared range), initialized to "World!". Prepend "Hello " by guarding that the combined length fits the capacity, shifting the old contents right and copying the literal in front, then print the used slice with Put_Line. If the guard fails, print a visible rejection message instead. About 12 lines.

## Proof obligations to watch

- **length**: The result is built in a fixed-capacity buffer, so the program's literal sizes make the prepend fit statically and the length checks discharge from constants.

## Language surface recorded by this assessment

String building and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting string with Put_Line.

Assessed on 2026-10-15 against page revision 413063 of the [task](https://rosettacode.org/wiki/String_prepend) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
