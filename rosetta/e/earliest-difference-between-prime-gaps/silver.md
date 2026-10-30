# Earliest difference between prime gaps

**Candidate: proofs plausibly discharge automatically.** Everything is arrays, ranged integers and procedure while loops with guards before each index or update, so no annotation is needed, but the 64-bit loop-carried sieve arithmetic and bounded tables to reach 10^6 need careful shaping.

Position 279 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A segmented sieve (base primes up to 65536 from a plain sieve, then fixed-size Boolean segments) enumerates consecutive primes in a procedure, recording the first start prime for each even gap in a fixed-size table of ranged 64-bit values. A while loop in a procedure advances the gap pair (g, g+2) until the absolute start difference exceeds the current power of ten, printing the pair via Put_Line with 'Image-built strings and moving to the next m. Guards reject with a visible message if the prime ceiling or gap-table bound would be exceeded. About 130 lines.

## Proof obligations to watch

- **overflow**: Segment offsets and prime values reach a few billion, so they use a 64-bit ranged subtype with a declared ceiling and a guard that stops with a visible limit-exceeded message before the ceiling is passed.
- **index**: The gap-start table is indexed by computed gaps, so each gap is guarded against the table's maximum before indexing, and the search stops with a visible outcome if the needed gap exceeds the table.
- **range**: Loop-carried values in the segmented sieve (current prime, last prime, segment base) are known only by type after the first iteration, so each is a ranged subtype with guards just before every update.
- **division**: Sieve marking uses mod and division by base primes, which are nonzero because the base-prime array holds only values of at least 2 by subtype.
- **termination**: All unbounded searches are while loops inside procedures, which get no termination check, and functions use only for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one result line per order of magnitude from 10^1 through 10^6.

Assessed on 2026-10-15 against page revision 413699 of the [task](https://rosettacode.org/wiki/Earliest_difference_between_prime_gaps) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
