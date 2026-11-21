# Feigenbaum constant calculation

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for loops with no recursion or while loops, but loop-carried floating-point values need range and nonzero guards before every update and division, so discharge depends on careful program shape. Formatting to 8 decimals also needs a guarded float-to-text conversion.

Position 1505 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

Use a bounded float subtype for a, x, y, d, a1, a2 and d1, with nested for loops over i in 2 .. 13, j in 1 .. 10 and k in 1 .. 2**i (about 160 thousand iterations total), embedding the initial values 1.0, 0.0 and 3.2. Before each float update and each division an explicit guard compares magnitudes and denominators and calls Reject on failure, and each row is printed by converting d to eight decimals in a bounded string buffer. About 55 lines.

## Proof obligations to watch

- **floating point**: The loop-carried x and y in x := a - x*x and y := 1.0 - 2.0*x*y are known only by type after the first iteration, so each is a bounded float subtype and an explicit guard just before each update rejects out-of-range values, which GNATprove can discharge but costs a visible Reject path.
- **division**: The divisions by y, d1 and (a - a1) are guarded by explicit nonzero tests with a specified rejection outcome, though a zero denominator cannot be excluded by types alone.
- **range**: The Newton updates of a feed back through 10 inner iterations per i, so a, a1, a2 and d need a bounded float subtype with guards to keep stored values in range.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, integers, exponentiation, for loops, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the table of i and the estimated Feigenbaum ratio d for each i.

Assessed on 2026-10-15 against page revision 413713 of the [task](https://rosettacode.org/wiki/Feigenbaum_constant_calculation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
