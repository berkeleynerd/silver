# Magnanimous numbers

**Candidate: proofs likely to discharge automatically.** All values are bounded by declared ranges (candidates below 10^6, sums below 2*10^6), indexes are guarded and loops are for loops or sit in a procedure, so no annotation is needed. The 400th magnanimous number is 602081, which fits within the cap.

Position 357 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function Is_Prime uses a for loop over divisors 2..1000 with an exit when d*d exceeds the value, and a constant array of powers of ten supplies the split points. A procedure runs a while loop over candidates (guarded by count < 400 and candidate < 1_000_000), treats 0..9 as magnanimous, and for larger numbers tests left + right sums for each power of ten not above the candidate, storing hits in a 400-element array. A final for loop prints the 1..45, 241..250 and 391..400 entries as index and value text. About 85 lines.

## Proof obligations to watch

- **overflow**: The candidate is a subtype capped at 999_999 and every split sum and trial-division square stays below 2_000_000, so all arithmetic is bounded by types.
- **index**: The results array has 400 slots and the store is guarded by count < 400 inside the while loop, with a visible message if the candidate cap is reached first.
- **termination**: The unbounded search is a while loop inside a procedure, which gets no termination check, and the primality function uses only a for loop.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the three requested groups of numbered magnanimous numbers, one per line.

Assessed on 2026-10-15 against page revision 414325 of the [task](https://rosettacode.org/wiki/Magnanimous_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
