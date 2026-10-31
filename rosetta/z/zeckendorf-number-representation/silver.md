# Zeckendorf number representation

**Candidate: proofs likely to discharge automatically.** Every check follows from a bounded remainder subtype, a guard comparing it to the array element just before each subtraction, and for-loop indexes over the array's own range, with no loop-carried value needing an invariant. The only added surface is basic integers, a constant array, for loops, integer-to-text conversion and non-newline output.

Position 91 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Embed a constant array of the Fibonacci numbers 1,2,3,5,8,13 and loop N over 0 .. 20; for each N, a for loop walks the array from largest to smallest, subtracting a Fibonacci number from a remainder of subtype 0 .. 20 only when the remainder is at least that number (greedy gives the unique Zeckendorf form). It prints each digit with Put, using a Boolean flag to drop leading zeros and printing a single "0" when N is zero, then ends the line with Put_Line. About 35 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the table of numbers 0 to 20 with their Zeckendorf strings to standard output.

Assessed on 2026-10-15 against page revision 411736 of the [task](https://rosettacode.org/wiki/Zeckendorf_number_representation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
