# Arithmetic numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic reduces to bounded integers and array indexing in for loops inside the main procedure, with guards before each accumulation, so checks should discharge without annotations, though the sieve's nonlinear index and the accumulator overflow guards need careful shape.

Position 923 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Build two fixed-size arrays (divisor count and divisor sum) over 1 .. 13_000 with a sieve using nested for loops (for i, for k in 1 .. Limit/i, adding i at index i*k), then scan n in order with a for loop, testing sum mod count = 0 to detect arithmetic numbers and counting composites (count > 2). It prints the first 100 in rows of ten with Put and 'Image-based padding, and prints the 1,000th and 10,000th numbers with their composite counts; the 100,000 and 1,000,000 stretch cases are omitted as optional because their arrays would be too large for the stack. About 80 lines.

## Proof obligations to watch

- **overflow**: Divisor sums are accumulated in loop-carried variables, so each addition is preceded by a guard against the integer maximum (with a visible rejection outcome), which is safe because real sums stay far below 2^31 for n up to 13,000.
- **index**: Sieve index i*k needs i*k <= Limit, which is obtained by looping k over 1 .. Limit/i, relying on the provers to handle this division-bounded product, or by a guard before each array access.
- **termination**: The outer search runs in the main procedure, not a function, and is a for loop over the sieve range, so no termination check or variant is needed.
- **range**: The count of arithmetic numbers found is capped at 10,000 by the array and loop bounds and checked by a guard before incrementing, so counters stay in range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the first 100 arithmetic numbers, the 1,000th and 10,000th arithmetic numbers, and the composite counts.

Assessed on 2026-10-15 against page revision 413641 of the [task](https://rosettacode.org/wiki/Arithmetic_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
