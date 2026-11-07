# Ranking methods

**Candidate: proofs likely to discharge automatically.** All data is a fixed seven-element array, indexes come from for loops or explicit bounds guards, and values stay within small ranged subtypes, so every check follows from types and local guards. Fractional rank is done in doubled integers, avoiding floating point, and no function needs a loop variant.

Position 898 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the seven scores as a constant array of a small ranged subtype and the names as a constant array of fixed-length space-padded Strings. Five procedures fill a rank array (Standard forward, Modified reverse, Dense, Ordinal, Fractional stored as doubled ranks) using for loops with neighbour comparisons guarded by loop bounds, and a print procedure formats each row with Integer'Image, writing the fractional half as '.5' when the doubled rank is odd. Fractional ties are handled with a for loop over positions that tracks the run start with a guard, so no loop invariant is needed. About 120 lines.

## Proof obligations to watch

- **overflow**: Dense-rank increments are loop-carried, so the program guards each increment against the 1..7 subtype bound (or derives the rank from the loop index) so no invariant is needed.
- **index**: Neighbour accesses at I-1 and I+1 are discharged by starting the for loop at 2 or ending it at 6, so the indexes stay inside the array's range.
- **range**: Fractional ranking stores doubled ranks (I+J-1) in a small ranged subtype, with run boundaries found by a bounded for loop guard rather than a while loop.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, procedures, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): The five ranking tables are printed line by line to standard output.

Assessed on 2026-10-15 against page revision 414430 of the [task](https://rosettacode.org/wiki/Ranking_methods) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
