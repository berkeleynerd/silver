# Zero to the zero power

**Candidate: proofs likely to discharge automatically.** The program is a single exponentiation of small constant-valued integers with one image conversion, so every check follows from declared types and the values 0 and 1 cannot overflow. Silver only lacks integer ** and 'Image output formatting today.

Position 1494 in the [progression](../../progression.md#stage-29), in stage 29, which adds exponentiation.

## Approach

Declare an Integer variable X := 0 and a Natural variable Y := 0, compute Z : Integer := X ** Y, and print "z=" concatenated with the image of Z using Put_Line. There are no loops, no input and no guards, because the operands are fixed and the result is statically in range. About 12 lines.

## Language surface recorded by this assessment

Integers, exponentiation, ranged subtypes and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed result of 0**0 to standard output.

Assessed on 2026-10-15 against page revision 415098 of the [task](https://rosettacode.org/wiki/Zero_to_the_zero_power) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
