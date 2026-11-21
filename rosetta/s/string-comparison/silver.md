# String comparison

**Candidate: proofs likely to discharge automatically.** Every check follows from String parameter bounds, an equal-length guard before the character loop and an 'A'..'Z' guard before the Character'Val shift, and the only loop is a for loop, so proof should discharge automatically.

Position 1472 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

A procedure Print_Comparison (A, B : String) prints the pair and then, through if statements, reports =, /=, <, >, <= and >= using Ada's built-in lexical String operators, with pieces written by Put and a final Put_Line. A Boolean function Equal_Ignoring_Case first returns False when lengths differ, then loops over A'Range comparing ASCII-lowercased characters of A and the corresponding offset index in B. Main calls it on embedded pairs including case variants ("THAT"/"That") and numeric strings ("10"/"9", showing they are compared lexically, not numerically). About 65 lines.

## Proof obligations to watch

- **index**: The case-insensitive comparison indexes B at B'First + (I - A'First) for I in A'Range, which discharges because an equal-length guard immediately precedes the loop.
- **range**: Lowercasing uses Character'Val (Character'Pos (C) + 32) only inside a guard C >= 'A' and C <= 'Z', so the result stays within Character.
- **length**: Strings of arbitrary parameter length are printed piecewise with Put rather than concatenated, so no result-length check on unbounded concatenation arises.

## Language surface recorded by this assessment

Procedures, functions, Boolean objects, unconstrained arrays, string ordering, string indexing, characters, for loops, integers and Put without a newline.

## External effects

- **console output** (allowed): Each comparison result for the embedded string pairs is printed to standard output.

Assessed on 2026-10-15 against page revision 413059 of the [task](https://rosettacode.org/wiki/String_comparison) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
