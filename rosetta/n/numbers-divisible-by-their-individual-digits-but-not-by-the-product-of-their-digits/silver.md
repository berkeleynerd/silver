# Numbers divisible by their individual digits, but not by the product of their digits

**Candidate: proofs likely to discharge automatically.** All values are bounded by types (N <= 999, digits <= 9, product <= 729) and every division is guarded by a nonzero test, with no loop-carried accumulator, so the checks should discharge from types and guards alone.

Position 138 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A for loop runs N over 1..999 and splits N into hundreds, tens and units digits typed 0..9 with / and mod, treating leading zeros as absent digits by branching on N < 10 and N < 100. For each digit present it rejects the number if the digit is zero or N mod digit is nonzero, then checks that N mod (product of present digits) is nonzero, and prints qualifying numbers with Put_Line of the integer image. About 45 lines.

## Proof obligations to watch

- **division**: Each mod by a digit or by the product is preceded by an explicit nonzero guard that returns false for zero digits, so the check follows from the guard.
- **overflow**: Digits are subtypes 0..9 and N is 1..999, so the product of at most three digits stays at most 729 with no loop-carried accumulator.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each qualifying number on its own line.

Assessed on 2026-10-15 against page revision 413807 of the [task](https://rosettacode.org/wiki/Numbers_divisible_by_their_individual_digits,_but_not_by_the_product_of_their_digits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
