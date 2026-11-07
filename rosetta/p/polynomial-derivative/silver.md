# Polynomial derivative

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by declared coefficient and degree ranges and all loops are for loops over array ranges in procedures, so every check follows from types and guards without annotations.

Position 610 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Represent a polynomial as a record holding a bounded coefficient array (index 0..8, coefficient subtype -1000..1000) and a degree; a procedure Differentiate fills an output polynomial with a for loop from 1 to Degree storing i*coef(i), with degree 0 giving the single coefficient 0. A formatting procedure builds each term into a bounded String buffer using 'Image and a guarded append, and the main procedure runs the five embedded test cases and prints each polynomial and its derivative. About 110 lines.

## Proof obligations to watch

- **overflow**: The product i*coef(i) is bounded by declaring coefficients in a small range such as -1000..1000 and degree at most 8, so it fits Integer.
- **length**: Output text is built in a fixed-size buffer sized for the worst-case term count and digits, with a guard before each append.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, records, for loops, procedures, Put without a newline, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each embedded test polynomial and its derivative as text lines.

Assessed on 2026-10-15 against page revision 411260 of the [task](https://rosettacode.org/wiki/Polynomial_derivative) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
