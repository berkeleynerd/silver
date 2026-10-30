# Hash join

**Candidate: proofs likely to discharge automatically.** All checks follow from declared subtypes, a per-step mod-bounded hash and a loop condition guarding chain indexing, with no function loops needing variants, so no annotation is required. The new surface (records, arrays, string indexing, 'Image, procedures) is large but each piece is routine for GNATprove.

Position 602 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Tables A and B are constant arrays of records (Age with a fixed 8-character padded Name; Character and Nemesis as fixed-length strings) embedded in the program. The hash phase builds a bucket-head array and a next-index array over table B (a chained multimap keyed by a mod-101 hash of the key characters), and the join phase loops over A, hashes the name, walks the chain with a while loop in a procedure, compares keys for equality and prints each joined row with Age converted by 'Image. About 110 lines.

## Proof obligations to watch

- **overflow**: The string hash is folded as h := (h * 31 + Character'Pos(c)) mod 101 with h declared in 0..100, so the intermediate stays below 4000 and every step is bounded by types alone.
- **index**: Chain walking uses a Row_Index subtype 0..5 where 0 means end of chain, and the while loop condition Idx /= 0 guards each Next(Idx) access.
- **termination**: The chain walk is a while loop inside a procedure, which gets no termination check, and the other loops are for loops.
- **length**: Names are fixed-length padded 8-character strings, and output text is built in a bounded buffer whose index is guarded against capacity before each write.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The joined rows are printed with Put_Line (and Put for table columns).

Assessed on 2026-10-15 against page revision 413998 of the [task](https://rosettacode.org/wiki/Hash_join) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
