# Sequence of primorial primes

**Candidate: proofs plausibly discharge automatically.** The loop structure is simple and bounded by static ranges, but correctness needs big-number multiplication and modular exponentiation within fixed capacity, so discharge depends on a verified big-number library and careful carry guards rather than annotations. The twenty-term case needs about 1200-digit numbers and costly primality tests, so the ten-term version is the realistic target.

Position 1386 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Sieve primes below 3200 into a Boolean array, then keep a fixed-capacity digit-array big number holding the running primorial, multiplied by each prime in a for loop. For each prime test primorial minus one and plus one with a deterministic-base Miller-Rabin over big modular arithmetic from an admitted fixed-capacity big-number library, printing each matching index with Put and a final Put_Line, rejecting if capacity would be exceeded. About 220 lines.

## Proof obligations to watch

- **overflow**: Fixed-capacity big-number multiply/add/subtract carry through loops, so digit and carry values must be bounded by the digit type and guarded against capacity overflow with a visible reject outcome.
- **other**: Primality of numbers with hundreds of digits (about 450 for index 457) needs a probabilistic test such as Miller-Rabin using big modular exponentiation, which requires an admitted library or heavy fixed-capacity code and is nonlinear.
- **termination**: All loops live in procedures (no termination check), and for loops are used where possible, so termination is not an obligation.
- **range**: Capacity must be sized for the 20-term output (primorial of 457 primes is roughly 1200 digits), and exceeding it must lead to a specified rejection rather than a silent change.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, big numbers, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the first ten (or twenty) primorial prime indices.

Assessed on 2026-10-15 against page revision 413906 of the [task](https://rosettacode.org/wiki/Sequence_of_primorial_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
