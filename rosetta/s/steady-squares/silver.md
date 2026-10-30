# Steady squares

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by the loop range, so the square cannot overflow, the modulus is a nonzero constant, and the for loop carries no values between iterations that need an invariant. Only integer arithmetic, 'Image output and a for loop are new.

Position 127 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A for loop runs N over a subtype 1 .. 9999, computes the square in a ranged Integer subtype (at most 99_980_001), and picks the modulus 10, 100, 1000 or 10000 with an if/elsif chain on N. If Square mod Modulus = N, it prints N, "^2 = " and the square using Integer'Image concatenated into a bounded line via Put_Line. About 35 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each steady square and its square, one line each.

Assessed on 2026-10-15 against page revision 408088 of the [task](https://rosettacode.org/wiki/Steady_squares) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
