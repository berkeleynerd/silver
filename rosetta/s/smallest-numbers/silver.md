# Smallest numbers

**Candidate: proofs plausibly discharge automatically.** Everything reduces to bounded digit-array arithmetic and a bounded substring scan, so checks follow from declared ranges and guards, but the carry loops and the length-guarded scanning require careful program shape.

Position 1362 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Store k**k as little-endian decimal digits in a Natural-length-bounded array, built by k repeated multiply-by-k passes with carry propagation, rejecting if capacity is exceeded. For each n from 0 to 50, split n into one or two digits and loop over k in 1..40, scanning the digit array for the pattern with guarded offsets and exiting at the first match, printing k, or reporting a visible not-found outcome if the bound is exhausted. All work is in procedures with for loops over declared ranges. About 90 lines.

## Proof obligations to watch

- **overflow**: Computing k**k needs about 135 bits for k=28, so it is held as a fixed-capacity decimal digit array where each digit times k plus carry stays within a small declared range.
- **index**: The digit count grows in a loop-carried variable, so each append is guarded by a check against the array capacity (about 70 digits for k up to 40), with Reject on exceeding it.
- **index**: The substring scan over the digit array needs offsets guarded against the current length before each comparison, since no invariant can be written.
- **termination**: The search over k is a bounded for loop (k in 1..40) with an explicit not-found outcome, in a procedure, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline, big numbers and Boolean objects.

## External effects

- **console output** (allowed): Prints the 51 smallest k values, one per line or space-separated, to standard output.

Assessed on 2026-10-15 against page revision 404749 of the [task](https://rosettacode.org/wiki/Smallest_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
