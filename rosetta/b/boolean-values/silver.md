# Boolean values

**Candidate: proofs likely to discharge automatically.** The program only needs Boolean declarations, if statements and string output, so every check is trivial and no loop or arithmetic is involved.

Position 1153 in the [progression](../../progression.md#stage-20), in stage 20, which adds enumerations.

## Approach

Declare Boolean constants and variables set to True and False, then use if statements on them and on comparison results to print which branch ran with Put_Line. Use the Boolean literal names directly as text, and use a plain if statement to show that only Boolean-typed expressions are valid conditions, so no other object stands for true or false. There are no loops, arrays or arithmetic. About 22 lines.

## Language surface beyond today's Silver

Boolean objects, enumerations and Put without a newline.

## External effects

- **console output** (allowed): The program prints lines showing the Boolean values and the results of conditionals.

Assessed on 2026-10-15 against page revision 412680 of the [task](https://rosettacode.org/wiki/Boolean_values) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
