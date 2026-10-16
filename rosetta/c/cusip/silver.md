# CUSIP

**Candidate: proofs likely to discharge automatically.** Fixed-length 9-character strings, small ranged integers and a for loop of eight steps make every index, range and overflow check follow from types and guards just before use, with invalid characters given a visible not-valid outcome.

Position 519 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A subtype Cusip_Text is String (1 .. 9) and a function Value_Of maps a character to 0..38 (digit, upper letter, '*', '@', '#') or reports invalid via a Boolean, using explicit range tests before each Character'Pos subtraction. A function Is_Valid loops with a for loop over 1 .. 8, doubles the value at even positions, adds V/10 + V mod 10 to a bounded sum, rejects any invalid character, then compares (10 - Sum mod 10) mod 10 with the ninth digit. A procedure Report takes a Cusip_Text and prints the code with valid or not valid, called for the six embedded codes from Main. About 55 lines.

## Proof obligations to watch

- **overflow**: The running sum is loop-carried, so each position's contribution is computed by a function returning a small ranged subtype and the sum is bounded by a ranged subtype with a guard (or the eight terms are added in one expression) so no invariant is needed.
- **range**: Character'Pos arithmetic on a validated character class yields a value in a small ranged subtype, discharged by the range test just before the subtraction.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints one valid or not valid line for each of the six embedded CUSIP codes.

Assessed on 2026-10-15 against page revision 414100 of the [task](https://rosettacode.org/wiki/CUSIP) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
