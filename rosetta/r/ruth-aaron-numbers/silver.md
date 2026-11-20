# Ruth-Aaron numbers

**Candidate: proofs plausibly discharge automatically.** Everything is integer trial division inside procedures with static bounds and guards, so checks are routine except the loop-carried sum accumulator and number formatting, which need careful guards but no annotations.

Position 272 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Prime_Sum(N, Distinct, S) trial-divides by F in a for loop over 2..224, using an inner while loop to divide out each factor and adding F once or per repeat, then adds any leftover cofactor greater than 1. A main-level procedure Find(Distinct) scans N from 2 up to 50000 comparing each sum with the previous one, stores the first 30 hits in a 30-element array, and prints them ten per line with Put and 'Image, or prints a not-found message otherwise. The optional triple stretch is left out. About 90 lines.

## Proof obligations to watch

- **overflow**: The prime-sum accumulator is loop-carried through nested loops, so each addition is guarded by a bound check on the running sum with a visible reject outcome, or the accumulator type is made large enough that the guard is never reached.
- **termination**: The divide-out while loop and the search loop live in procedures, which get no termination check, so none is required.
- **range**: The search is bounded by a fixed limit of 50000 and the program prints an explicit not-found message if fewer than 30 are found, so the bound never silently alters results.
- **index**: Result storage is an array of 30 entries indexed only after a count < 30 guard, and trial factors run over a static for range 2..224 covering the square root of the limit.
- **division**: Divisors are loop indexes starting at 2, so mod and / are statically nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building and arrays.

## External effects

- **console output** (allowed): Prints the two lists of 30 numbers with headings.

Assessed on 2026-10-15 against page revision 414014 of the [task](https://rosettacode.org/wiki/Ruth-Aaron_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
