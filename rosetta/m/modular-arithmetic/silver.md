# Modular arithmetic

**Candidate: proofs likely to discharge automatically.** Every operation is on a modular type whose arithmetic wraps by definition, so no run-time check can fail and there are no loops or recursion to need annotations; the only wrinkle is bounded text building for the output line.

Position 1257 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Declare type Mod13 is mod 13 and a function F (X : Mod13) return Mod13 returning X**100 + X + 1, where modular operators wrap by definition and carry no overflow checks. Main calls F on a constant Mod13 value 10 and prints the result with Mod13'Image concatenated with literal text; there is no input, loop, or recursion. About 16 lines.

## Proof obligations to watch

- **length**: The concatenation of the 'Image text with literals needs a static length bound, which the modulus 13 gives because the image is at most 3 characters.

## Language surface recorded by this assessment

Modular types, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the line reporting f(10) modulo 13 via Put_Line.

Assessed on 2026-10-15 against page revision 415516 of the [task](https://rosettacode.org/wiki/Modular_arithmetic) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
