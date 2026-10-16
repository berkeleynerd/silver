# Exponentiation with infix operators in (or operating on) the base

**Candidate: proofs likely to discharge automatically.** All values are small and bounded by declared subtypes and for-loop ranges, so overflow, range and length checks follow from types and no loop invariant or recursion is needed. The only open question is the new surface (integer image, exponentiation, string building), not provability.

Position 1506 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

Use the integer case only: subtype Base is Integer range -5 .. 5 and subtype Power is Integer range 2 .. 3, with a for loop over the two bases (the variable set to -5 then 5) and an inner for loop over the powers. Each iteration builds one line from 'Image of x and p and of the four expressions -x**p, -(x)**p, (-x)**p and -(x**p), and prints it with Put_Line. There is no input, so there are no guards beyond the types. About 40 lines.

## Proof obligations to watch

- **overflow**: x ** p and its negation are bounded by ranged subtypes (x in -5..5, p in 2..3, so at most 125 in magnitude), so the overflow checks discharge from types alone.
- **length**: Concatenating 'Image text of ranged integers into one Put_Line argument needs the bounded image lengths to be known, which follows from the subtype ranges but depends on how the library handles 'Image.

## Language surface recorded by this assessment

Integers, exponentiation, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one result line per base and power, plus a heading, to standard output.

Assessed on 2026-10-15 against page revision 413710 of the [task](https://rosettacode.org/wiki/Exponentiation_with_infix_operators_in_%28or_operating_on%29_the_base) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
