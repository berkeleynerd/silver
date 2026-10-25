# Modular inverse

**Candidate: proofs likely to discharge automatically.** A bounded exhaustive search over a ranged loop index computes the inverse (1969, equivalent to -48) so that A * X is at most about 85000 and mod by the constant 2017 is never a division by zero, with no loop-carried arithmetic and no recursion or while loop needing a variant.

Position 108 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main declares constants A = 42 and M = 2017, a ranged subtype Candidate 1..M-1, and a Boolean Found with an Integer Inverse initialized to 0. A for loop over Candidate tests (A * X) mod M = 1 and records the first match, then Main prints the inverse, or a specified "no inverse exists" message when none was found. About 25 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed inverse of 42 modulo 2017 with Put_Line.

Assessed on 2026-10-15 against page revision 414758 of the [task](https://rosettacode.org/wiki/Modular_inverse) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
