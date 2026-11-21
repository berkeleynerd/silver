# Exponentiation order

**Candidate: proofs likely to discharge automatically.** Every operand is a static literal so the overflow checks on 15625 and 1953125 are decided at compile time and discharge trivially; the program has no loops, recursion or input.

Position 1493 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

Declare Integer constants for (5**3)**2 and 5**(3**2) with all operands static literals, then print each with a literal label and Integer'Image concatenated via Put_Line. A third line states that unparenthesised 5**3**2 is not valid Ada, so Silver source must parenthesize. About 14 lines.

## Language surface recorded by this assessment

Integers, exponentiation, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the labelled result lines with Put_Line.

Assessed on 2026-10-15 against page revision 415474 of the [task](https://rosettacode.org/wiki/Exponentiation_order) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
