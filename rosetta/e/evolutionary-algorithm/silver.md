# Evolutionary algorithm

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed string length, for-loop indexes over array ranges, modular generator arithmetic and a bounded generation counter, with the while loop confined to a procedure, but the program shape (state threaded through procedures, a generation cap that adds a visible non-convergence outcome) needs care.

Position 1297 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Strings are fixed 28-character arrays over a 27-letter alphabet (A..Z and space), with a modular-type LCG supplying deterministic pseudo-random values seeded by a constant. Mutate is a procedure copying the parent and replacing each position when a 0..99 draw falls below the integer mutation percentage; the main loop makes 100 children per generation in a fixed array, picks the fittest of the children and the parent by a for-loop fitness count, and stops when fitness equals 28 or a generation cap is reached, printing progress every 20th generation with a bounded 'Image conversion. About 120 lines.

## Proof obligations to watch

- **termination**: The outer while loop runs only inside a procedure, which gets no termination check, and a fixed generation cap with a visible 'not converged' message keeps it honest and bounded.
- **overflow**: The deterministic LCG state is a modular 32-bit type so wraparound is by definition, and the generation counter is a range-limited integer capped by the generation limit.
- **range**: Mapping a random value to a character uses mod 27 on a modular value into a 27-letter alphabet array index, which discharges because the remainder is bounded by the divisor.
- **index**: All string and children-array indexing is in for loops over the array's own range or by the fixed 28-length constants, so bounds are static.
- **other**: The mutation rate is expressed as an integer percentage compared with a 0..99 pseudo-random draw, avoiding floating point entirely.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, string indexing, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the initial parent, periodic generation progress and the final converged string with its fitness.

Assessed on 2026-10-15 against page revision 414190 of the [task](https://rosettacode.org/wiki/Evolutionary_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
