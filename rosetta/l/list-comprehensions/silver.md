# List comprehensions

**Candidate: proofs likely to discharge automatically.** The only loop-carried value is the Count, which is guarded against capacity, and all arithmetic is bounded by small subtype ranges so every check follows from types and local guards; the list comprehension itself is rendered as nested for loops since Ada has no such construct.

Position 582 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed n = 20 as a constant, declare a ranged subtype 1 .. 20 and an array of triple records (or three parallel arrays) with a Count variable, and fill it with three nested for loops (A in 1..N, B in A+1..N, C in B+1..N) testing A*A+B*B = C*C and appending only when Count is below capacity. Then loop over 1..Count in a procedure and print each triple with Put and 'Image text, so no recursion, access types or while loops are required. About 45 lines.

## Proof obligations to watch

- **overflow**: A*A+B*B and C*C are bounded because A, B, C are subtype-ranged loop indexes with a constant Max of 20 so products stay far below Integer'Last.
- **index**: Appending to the fixed-capacity result array is guarded by a Count < capacity test, with the capacity chosen above the number of triples (6 for n=20) and overflow reported visibly.
- **length**: The output line is built in a bounded buffer whose size is sized for the maximum count of triples, with each append preceded by a length guard.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, records, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the list of triples to standard output.

Assessed on 2026-10-15 against page revision 415006 of the [task](https://rosettacode.org/wiki/List_comprehensions) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
