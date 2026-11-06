# Numbers in base 10 that are palindromic in bases 2, 4, and 16

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by small constants (values below 25000, 32 digits suffice for base 2), and every loop is a for loop, so checks follow from types and guards without annotations.

Position 319 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function Is_Palindrome (N : Natural; Base : Positive range 2..16) fills a fixed 32-entry digit array with a for loop (instead of a while loop, so the function needs no variant), peeling digits with mod and / while the remaining value is positive and the counter is below 32, then compares mirrored digits in a for loop over half the count. Main loops N over 0 .. 24999 and prints N'Image via Put_Line when Is_Palindrome holds for bases 2, 4 and 16, joined with and then. About 45 lines.

## Proof obligations to watch

- **overflow**: The digit counter is a loop-carried value, discharged by a subtype range of 0..32 plus an explicit guard before each increment.
- **index**: Digit array accesses use the counter and mirrored indexes, discharged by the counter's range subtype and for-loop bounds derived from it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each qualifying number on its own line.

Assessed on 2026-10-15 against page revision 408884 of the [task](https://rosettacode.org/wiki/Numbers_in_base_10_that_are_palindromic_in_bases_2,_4,_and_16) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
