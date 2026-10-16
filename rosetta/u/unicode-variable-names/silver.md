# Unicode variable names

**Candidate: proofs likely to discharge automatically.** The program is straight-line code on one Integer whose value is statically 1 before the increment, so the overflow check on the addition and the initialization checks discharge trivially. The only new surface is integer variables and 'Image, and the Unicode identifier is just a source-encoding matter that changes no proof.

Position 39 in the [progression](../../progression.md#stage-2), in stage 2.

## Approach

Declare an Integer variable named Δ initialised to 1 in Main, add 1 to it in a straight-line assignment, and print Integer'Image of it with Silver_IO.Put_Line after a literal line describing Ada's Unicode identifier rules. There are no loops, calls or inputs, so no guards are needed. About 12 lines.

## Language surface recorded by this assessment

Integers and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the incremented value of the variable named Δ, plus a short text describing Ada's identifier rules.

Assessed on 2026-10-15 against page revision 413955 of the [task](https://rosettacode.org/wiki/Unicode_variable_names) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
