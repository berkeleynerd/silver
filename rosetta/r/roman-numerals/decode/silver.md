# Roman numerals/Decode

**Candidate: proofs likely to discharge automatically.** The decoder is a single for loop over a bounded string with a character-to-value case statement, so index checks follow from the loop range and the accumulator is bounded by the length cap times 1000, which fits in Integer.

Position 774 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

Embed the 14 example numerals as fixed-length String constants (a table of strings in an array of a bounded record or a procedure called per numeral), and decode each with a procedure that loops over the string's own index range. Each character maps through a case statement to its value (invalid letters set a rejected flag), and each digit is added, or subtracted when the next digit is larger, into a total whose maximum is bounded by the length cap. Results are printed with Image conversion of the total and a pass/fail comparison against the expected value. About 70 lines.

## Proof obligations to watch

- **overflow**: The running total is loop-carried, so it is held in an Integer-range subtype with each digit value at most 1000, and the length is capped at a fixed bound (for example 32) with an over-length numeral rejected visibly, so the sum stays within range.
- **range**: The subtractive step is computed by comparing each digit with the next and adding or subtracting its value, and unknown letters give a visible rejection outcome, so no value leaves its range.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, arrays, for loops, case statements, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded numeral with its decoded value and a pass/fail result.

Assessed on 2026-10-15 against page revision 414448 of the [task](https://rosettacode.org/wiki/Roman_numerals/Decode) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
