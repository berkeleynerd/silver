# Nested templated data

**Candidate: proofs likely to discharge automatically.** Every check follows from for loops over the arrays' own ranges, a depth counter guarded before each increment and decrement, and an index range guard just before each payload lookup, so no annotation is needed. Flat token encoding avoids recursion and heap use, so the nested tree is traversed iteratively with fixed bounds.

Position 1170 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The template is a constant array of token records (Open, Close or Leaf with an index) encoding [[[1,2],[3,4,1],5]], the payloads are a constant array of 9-character strings, and a Boolean Used array is marked during a single for loop over the tokens. The loop prints brackets, separators and newlines with Put and Put_Line, tracking nesting depth and the previous token kind, with guards before each depth change and each payload lookup. A second for loop over the payload range lists the unused payloads (0 and 6), and an index without a payload prints a visible missing marker. About 70 lines.

## Proof obligations to watch

- **range**: Each template index is checked against the payload range 0..6 by an if guard just before the array access, and an out-of-range index prints a visible missing marker.
- **overflow**: The nesting depth counter, the only loop-carried arithmetic value, is incremented only under a guard against its declared maximum and decremented only when above zero, with an out-of-bounds template rejected visibly.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, enumerations, arrays, records, case statements, for loops and Put without a newline.

## External effects

- **console output** (allowed): The nested payload structure and the list of unused payloads are written to standard output.

Assessed on 2026-10-15 against page revision 412938 of the [task](https://rosettacode.org/wiki/Nested_templated_data) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
