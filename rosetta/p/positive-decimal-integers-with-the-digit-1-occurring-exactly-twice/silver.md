# Positive decimal integers with the digit 1 occurring exactly twice

**Candidate: proofs likely to discharge automatically.** All arithmetic is on values bounded by 999 with a digit counter that is at most three, so overflow, range and division checks follow from types and loop bounds. The while loop sits in a procedure, so it gets no termination check, and the counter fits its type because the number has at most three digits.

Position 182 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Main uses a for loop over N in 1 .. 999 and, for each N, a while loop in the main procedure that copies N into a Natural, divides it by 10 until zero and counts digits equal to 1 in a count subtype bounded 0 .. 3. When the count is exactly 2, the value is printed with Put and a separating space, then New_Line ends the line. About 30 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the matching integers to standard output.

Assessed on 2026-10-15 against page revision 406172 of the [task](https://rosettacode.org/wiki/Positive_decimal_integers_with_the_digit_1_occurring_exactly_twice) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
