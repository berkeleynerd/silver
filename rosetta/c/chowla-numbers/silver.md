# Chowla numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges and for-loop indexes except the loop-carried divisor sum and the comma-formatting buffer, which need careful guards but no annotation. The prime-count loop is heavy at runtime but not a proof concern.

Position 929 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A function Chowla (N in 1 .. 35_000_000) returns a Long_Long_Integer sum by a for loop I in 2 .. 5916 that adds I and N/I when I*I <= N and N mod I = 0 (guarded against double counting). Procedures loop over 1 .. 37, count zeros over 2 .. 10_000_000 printing at each power of ten, and test triangular-style candidates K*(K+1)/2 up to the limit for Chowla(P) = P-1, with numbers formatted with commas in a bounded buffer. Divisions use nonzero loop indexes and accumulator additions are guarded. About 110 lines.

## Proof obligations to watch

- **overflow**: The divisor-sum accumulator is loop-carried with no invariant, so it is given a wide range type and an explicit guard before each addition that leads to a visible outcome, since its true bound (sigma of n) cannot be stated.
- **termination**: Trial division is a for loop over 2 .. 5916 with an if I*I <= N test inside, so the function needs no variant, while only the driver loops in procedures use while.
- **index**: Comma-formatted number text is built in a fixed 16-character buffer with a position counter that must be guarded before each write.
- **range**: The perfect-number triangular generator K and Kk values grow in a loop, so they need a type wide enough plus an exit guard before multiplication.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, functions, procedures, 'Image of scalars, string building, characters, string indexing, arrays and conditional expressions.

## External effects

- **console output** (allowed): Prints the 37 chowla lines, the prime counts and the perfect numbers with Put_Line.

Assessed on 2026-10-15 against page revision 413665 of the [task](https://rosettacode.org/wiki/Chowla_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
