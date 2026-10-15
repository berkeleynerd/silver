# Binary strings

**Candidate: proofs plausibly discharge automatically.** Every operation is a bounded array scan whose indexes are range-typed and guarded just before use, with capacity overflow producing a visible outcome, so no annotation is needed. The loop-carried positions in replace-all and join make discharge depend on careful guard placement rather than being routine.

Position 632 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Represent a binary string as a record holding a Length in 0..Capacity and a fixed array of Octet (Integer subtype 0..255) of size Capacity. Creation, assignment, cloning, emptiness, comparison, append, substring and join are small procedures and for-loop functions with explicit capacity and range guards that report Overflow or invalid-range outcomes; replace-all is a procedure with a while loop that scans the source and writes to the output only after checking remaining capacity. A main procedure runs embedded example data through every operation and prints the results. About 130 lines.

## Proof obligations to watch

- **overflow**: Append, join and replace could exceed the fixed capacity, so each checks remaining room just before writing and sets a visible Overflow outcome instead of truncating.
- **index**: Substring and replace use loop-carried read and write positions, which discharge because they are Natural subtypes bounded by the capacity and guarded immediately before each array access.
- **termination**: Replace scans with a while loop, so it is a procedure with a position that always advances; functions use only for loops, so no variant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The demo prints each operation's result (lengths, equality, byte values) to standard output.

Assessed on 2026-10-15 against page revision 415347 of the [task](https://rosettacode.org/wiki/Binary_strings) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
