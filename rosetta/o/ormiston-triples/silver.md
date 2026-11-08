# Ormiston triples

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges, array bounds and guards before each write, with only loop-carried segment offsets and signature sums needing careful range design, and no annotation is required because loops sit in procedures.

Position 280 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Sieve primes below 31623 once into a Boolean array, then sweep 1..1e9 in fixed-size odd-only segments, striking multiples of each small prime with guarded while loops in a procedure. For each surviving prime compute a digit-count signature (sum of 16**digit) with a bounded procedure, compare with the two previous primes' signatures, record the first 25 smallest members in a 25-element array, and count all triples; print with Put_Line using 'Image concatenation. The stretch to ten billion is omitted as optional. About 110 lines.

## Proof obligations to watch

- **overflow**: Digit-count signatures and sieve offsets are carried through loops, so they are held in Long_Long_Integer-ranged subtypes with explicit guards sized so 10 digits at weight 16 and offsets below 2**31 cannot overflow.
- **index**: Segmented-sieve strike indexes are loop-carried, so each strike loop is a while loop in a procedure guarded by a comparison against the segment length just before each array write.
- **termination**: The digit-extraction and strike while loops live in procedures, which get no termination check, so no variant is needed.
- **other**: A full sieve to one billion needs a huge array, so a fixed-size segment (for example 2**20 odd numbers) plus a small-prime table up to 31623 keeps resource limits modest, at the cost of more index arithmetic to prove.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the smallest members of the first 25 triples and the count of triples up to one billion.

Assessed on 2026-10-15 against page revision 414007 of the [task](https://rosettacode.org/wiki/Ormiston_triples) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
