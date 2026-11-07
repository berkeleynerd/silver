# Attractive numbers

**Candidate: proofs plausibly discharge automatically.** All values are bounded by 120 and the factor count by a small cap, so every check follows from types and a single guard, though loop-carried N and Count need careful shaping and a procedure-based while loop.

Position 370 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

For each I in 2..120 a procedure counts prime factors by looping F over 2..120 and, inside, a while loop dividing the remaining value N while N mod F = 0, incrementing a guarded Count. A second small primality test on Count (at most 6) checks it against 2, 3, 5 by comparison, and attractive numbers are printed with Put using 'Image padded to width 5, emitting a newline after every 20th. The 1 case is excluded since it has zero factors, which is not prime. About 55 lines.

## Proof obligations to watch

- **overflow**: The loop-carried factor count is only known by its type after the first iteration, so the increment is preceded by a guard against a generous cap that can never trigger since 120 has at most 6 prime factors.
- **termination**: The divide-out loop is a while loop, so it lives in a procedure (no termination check) rather than a function, and is bounded by the enclosing for loop over candidate factors.
- **division**: The divisor is the for-loop index of 2..120, whose type range excludes zero.
- **range**: The remaining quotient is a subtype of 1..120 and N/F with F at least 2 stays in range, which the provers handle without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the header line and the attractive numbers up to 120, 20 per row.

Assessed on 2026-10-15 against page revision 413644 of the [task](https://rosettacode.org/wiki/Attractive_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
