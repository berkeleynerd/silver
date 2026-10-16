# Hash from two arrays

**Candidate: proofs likely to discharge automatically.** All loops are for loops over array index ranges and all indexes and slices are bounded by declared subtypes, so the checks follow from types and guards with no loop-carried invariants needed.

Position 602 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Two constant fixed-size arrays (keys as 3-character strings, values as padded 6-character strings with a length array) are embedded, and a bounded table of entries (key, value, length, used flag) of fixed capacity plays the hash object. A procedure inserts each pair by scanning existing slots for an equal key (overwriting it) or taking the next free slot, rejecting with a visible message if the table is full, and a for loop then looks up and prints each key's value by scanning with String equality. About 70 lines.

## Proof obligations to watch

- **index**: Slice bounds for the padded value text and the table slot are discharged by declared index subtypes and a stored length component constrained to its range, with a capacity guard before each insert.

## Language surface recorded by this assessment

Ranged subtypes, arrays, records, string indexing, integers, for loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints each key => value pair with Put_Line.

Assessed on 2026-10-15 against page revision 411615 of the [task](https://rosettacode.org/wiki/Hash_from_two_arrays) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
