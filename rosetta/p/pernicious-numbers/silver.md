# Pernicious numbers

**Candidate: proofs plausibly discharge automatically.** All operands are bounded by declared integer ranges and for-loop ranges, with no recursion or while loops, so only the unannotated accumulator needs a small explicit guard to discharge.

Position 370 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A constant Boolean array marks primes 0..64, and a function computes the population count with a for loop of 31 iterations halving a copy of the number with / 2 and mod 2, using a capped accumulator. The first 25 pernicious numbers come from a for loop over 1..100 with a found counter guarded below 25 before each print, and the range 888_888_877..888_888_888 is a second for loop; each qualifying number is printed with Put of its image. About 45 lines.

## Proof obligations to watch

- **overflow**: The population-count accumulator is loop-carried with no invariant, so each increment is guarded by a comparison against a small cap (unreachable for 30-bit inputs but visible) to make the addition provably safe.
- **range**: The count indexes a Boolean prime table of 0..64, so the accumulator's subtype range or the cap guard must bound it before indexing.
- **overflow**: The candidate number is a loop-carried counter; using for loops over fixed integer ranges (1..100 with a found-count guard, and 888_888_877..888_888_888) keeps it bounded by the loop range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, functions, procedures, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Two lines of space-separated decimal numbers are written to standard output.

Assessed on 2026-10-15 against page revision 414399 of the [task](https://rosettacode.org/wiki/Pernicious_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
