# Associative array/Creation

**Candidate: proofs likely to discharge automatically.** The task only requires creating and using a small map, which maps cleanly to a fixed-capacity array of key/value entries with for-loop lookup, so every index and range check follows from types and guards.

Position 598 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

The map is a fixed-capacity record holding a Count, an array of key records (a 16-character buffer plus its length) and an array of bounded integer values. Insert and Find are procedures with an out Found flag, using for loops over the entry array and guarded comparison of the key slice, and Main inserts Red, Blue and Yellow with their values and prints each lookup. A full table or missing key yields an explicit Found or Inserted False outcome that Main reports. About 60 lines.

## Proof obligations to watch

- **index**: Entry count is a subtype ranged 0..Capacity, insertion is guarded by Count < Capacity, and lookup uses a for loop over the array's own index range.
- **length**: Keys are stored in fixed 16-character buffers with a length field, and a guard rejects keys longer than the buffer with a visible failure outcome.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, records, for loops, procedures, functions, Boolean objects, string indexing, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each key and its retrieved value with Put_Line.

Assessed on 2026-10-15 against page revision 411543 of the [task](https://rosettacode.org/wiki/Associative_array/Creation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
