# Increasing gaps between consecutive Niven numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges, a bounded digit loop and for-loop indexes, with only simple guards before counter increments and the division, so proofs should discharge without annotations. The main new surface is integer arithmetic with mod and /, loops, and numeric text output.

Position 351 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A main procedure runs a for loop over n from 1 to a fixed documented limit (about 150 million, enough for the ten millionth Niven number) in a 64-bit ranged subtype, computing each digit sum with a bounded inner for loop of 10 digit extractions using mod and /, and testing divisibility under a sum > 0 guard. It keeps previous, largest gap, gap index and Niven index as ranged variables, printing a row via Put plus a small digit-by-digit number formatter into a bounded buffer whenever a gap exceeds the previous maximum, with an explicit guard before incrementing counters. About 70 lines.

## Proof obligations to watch

- **overflow**: Counters and the gap sum are held in a 64-bit Long_Long_Integer with declared ranges far below its limits, and the counter increments are preceded by explicit limit guards.
- **division**: The digit sum starts at zero but n >= 1 means the loop adds at least one digit, so a guard 'if sum > 0' just before the divisibility test makes the mod check discharge.
- **termination**: The digit-sum loop is a bounded for loop over at most 10 digits inside a procedure, and the outer search is a for loop, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the table of increasing gaps.

Assessed on 2026-10-15 against page revision 412063 of the [task](https://rosettacode.org/wiki/Increasing_gaps_between_consecutive_Niven_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
