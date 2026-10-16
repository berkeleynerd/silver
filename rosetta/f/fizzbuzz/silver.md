# FizzBuzz

**Candidate: proofs likely to discharge automatically.** Every check follows from the static loop range 1 .. 100 and constant divisors, so mod cannot divide by zero, 'Image of the bounded index has a known maximum length, and the for loop terminates by itself.

Position 107 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A parameterless Main uses a for loop over the static range 1 .. 100 with an integer loop index, and tests I mod 15, I mod 5 and I mod 3 in an if/elsif/else chain. Each branch calls Silver_IO.Put_Line with the literal Fizz, Buzz or FizzBuzz, and the else branch prints the number's text image with the leading space trimmed. No loop-carried state exists, so nothing needs a guard. About 16 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints 100 lines, one per integer, to standard output via Put_Line.

Assessed on 2026-10-15 against page revision 415487 of the [task](https://rosettacode.org/wiki/FizzBuzz) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
