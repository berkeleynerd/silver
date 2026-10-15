# Ulam spiral (for primes)

**Candidate: proofs plausibly discharge automatically.** Everything uses static bounds, for loops and a small fixed grid, so only the nonlinear spiral index formula and sieve index arithmetic need guard-shaped code, with no annotations required.

Position 914 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed a fixed Size (for example 29) and compute a Boolean sieve array over 1..Size*Size using nested for loops, then for each row build a fixed-length String buffer by assigning a dot or space per cell, where the cell number comes from the closed-form spiral formula in a ranged subtype. Each finished row is emitted with Silver_IO.Put_Line, with explicit guards on the computed number before each array index. All loops are for loops over static ranges and everything sits in procedures or simple functions. About 55 lines.

## Proof obligations to watch

- **overflow**: The closed-form cell number (L-1)**2 + D is nonlinear, so it is computed in an Integer type with small constant Size, where the bounded operands make overflow checks routine for the provers.
- **range**: Proving the cell number lies in 1..Size*Size needs nonlinear reasoning, so the program guards the value before indexing the sieve and treats an out-of-range value as not prime, which is never reached.
- **index**: Sieve marking of I*J relies on J being at most Max/I, so a guard before the store keeps the index within the array.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, procedures, functions and conditional expressions.

## External effects

- **console output** (allowed): The spiral rows are printed as text lines of dots and spaces, which also satisfies the terminal-filling demonstration.

Assessed on 2026-10-15 against page revision 414991 of the [task](https://rosettacode.org/wiki/Ulam_spiral_%28for_primes%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
