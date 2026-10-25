# Sequence: nth number with exactly n divisors

**Candidate: proofs plausibly discharge automatically.** The program needs no annotation because every loop is a bounded for loop and the arithmetic is bounded by declared subtypes. Discharge still depends on careful shape: guarded counter increments, a subtype-bounded carry, and a capacity guard on the big-number digit array, which together make the outlook plausible rather than likely.

Position 1369 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

For each n from 1 to 15, the program checks whether n is prime by trial division. If it is, the term is the n-th prime raised to the power n-1, computed by repeatedly multiplying a fixed 30-digit decimal array by a small factor, because 41^12 is about 2.26e19 and does not fit in 64 bits. Otherwise a bounded for loop scans candidates 1..10000, counts divisors by trial division up to the square root, and records the n-th match using a Found flag. All loops are for loops in Main, and a capacity or search-limit guard prints an explicit failure line. About 100 lines.

## Proof obligations to watch

- **overflow**: Loop-carried divisor and match counters are incremented inside for loops where the prover knows only their type, so each increment needs a declared range plus a guard just before it that leads to a visible failure line.
- **range**: The carry in the digit-array multiply stays in a declared subtype because digit (at most 9) times prime (a subtype up to 50) plus carry, divided by 10, provably fits the subtype using only the types.
- **index**: The top digit position grows across the repeated multiplications, so it needs a capacity guard before each extension that reports overflow instead of writing past the 30-digit array.
- **overflow**: The trial-division test d * d <= m is nonlinear, but it discharges because d and m are both in declared ranges of at most 10000, so the product fits in Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, big numbers, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the first 15 terms of the sequence, one per line.

Assessed on 2026-10-15 against page revision 413907 of the [task](https://rosettacode.org/wiki/Sequence:_nth_number_with_exactly_n_divisors) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
