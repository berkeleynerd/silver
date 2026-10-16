# Radical of an integer

**Candidate: proofs plausibly discharge automatically.** Everything is a sieve over a fixed one-million array with bounded subtypes and explicit guards in procedures, so no annotation is needed, but the loop-carried products and counters require careful guard placement to discharge.

Position 423 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Use fixed arrays indexed 1..1_000_000 holding the radical and distinct-prime count, filled by a sieve in a procedure: for each p still marked prime, a while loop steps multiples m (guarded m <= Limit - p) multiplying the radical by p and incrementing the count, each under an explicit guard. Then print rows of 10 radicals for 1..50, the three spot radicals, the 0..7 distribution via a count array, and the bonus prime count and prime-power count from a separate sieve loop, formatting numbers with 'Image and Put. About 160 lines.

## Proof obligations to watch

- **overflow**: Loop-carried products and sums (radical accumulator, multiple stepping m + p, count increments) are kept in bounded subtypes and each is guarded just before use, e.g. only multiply when the factor is at most Limit divided by the current radical.
- **index**: Sieve and count array indices come from loop variables whose bounds are guarded by explicit comparisons (m <= Limit - p, c <= 7) before each indexing.
- **range**: The distinct-factor counter cannot be proved within 0..7 without an invariant, so the increment is guarded by an explicit count < 7 test with a visible reject otherwise.
- **termination**: All while loops (sieve stepping, trial division) live in procedures, which get no termination check, so no variant is needed.
- **overflow**: Per-bucket counters over one million numbers need a counter type of range at least 1,000,000 with a guarded increment since accumulation is loop-carried.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the first 50 radicals, the three spot radicals, the distinct-factor distribution and the bonus prime counts.

Assessed on 2026-10-15 against page revision 415554 of the [task](https://rosettacode.org/wiki/Radical_of_an_integer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
