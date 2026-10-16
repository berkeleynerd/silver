# Giuga numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from for-loop ranges, a ranged candidate subtype and nonzero constant divisors, and only a procedure is needed, so no loop-carried value requires an invariant. The fixed search limit is a documented resource bound, and the stretch part is optional.

Position 892 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A procedure Check (M : in Candidate; Giuga : out Boolean) divides a remainder by each trial factor F in a for loop over 2 .. 300 (enough since sqrt(100000) < 317, with any leftover cofactor treated as a final prime), tracking the distinct prime factor count and failing as soon as (M/F - 1) mod F /= 0. A for loop over candidates 3 .. 100000 calls it, stores hits into a 4-element array under a Count < 4 guard and exits when Count = 4, then prints the numbers with 'Image and Put. If fewer than four are found within the limit, an explicit message is printed instead; the fifth number (about 2.4e10) is optional and left out. About 55 lines.

## Proof obligations to watch

- **overflow**: Candidates are confined to a for-loop range of 3 .. 100000 in a ranged subtype, so no increment or division can overflow, and the reduced remainder stays within its declared subtype.
- **index**: The result array has 4 slots and is written only under an explicit Count < 4 guard just before the store.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the first four Giuga numbers.

Assessed on 2026-10-15 against page revision 411964 of the [task](https://rosettacode.org/wiki/Giuga_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
