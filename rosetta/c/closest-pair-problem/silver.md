# Closest-pair problem

**Candidate: proofs likely to discharge automatically.** Integer coordinates in a bounded subtype make every squared-distance, index and accumulator check follow from types, and only for loops are used so no termination or invariant is needed.

Position 63 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Points are two constant arrays of ranged integer coordinates (X and Y, 10 entries, embedded from the task example, scaled to integers instead of Float), and a brute-force double for loop compares squared distances (no square root) while tracking the best pair indices and best squared distance in variables typed by their ranges. The point count is a fixed constant of at least 2, so the N<2 case is excluded by declaration, and results are printed with 'Image concatenations through Silver_IO.Put_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: Coordinates are a subtype 0..10000 so each squared difference is at most 10**8 and the sum of two fits in Integer, discharged from types alone.
- **index**: Nested for loops run over the array's own index subtype with the inner range starting at I+1, so every index check is static.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the closest pair and its distance with Put_Line.

Assessed on 2026-10-15 against page revision 415309 of the [task](https://rosettacode.org/wiki/Closest-pair_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
