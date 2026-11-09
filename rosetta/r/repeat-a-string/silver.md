# Repeat a string

**Candidate: proofs likely to discharge automatically.** The task is just bounded string building with nested for loops, and the type-bounded indexes (Count and Len ranged, buffer sized as their product) discharge every check without invariants or recursion.

Position 494 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The program declares a ranged Count (0..10) and a constant source string, and fills a fixed-capacity String buffer using nested for loops (outer over repetitions, inner over the source's own range) with write positions computed from the loop indexes. A second loop fills a buffer with a single character for the repeat-char variant. It prints the prefix slice of the buffer with Put_Line for ha x5 and * x5. About 35 lines.

## Proof obligations to watch

- **index**: Each write position is Start + (I-1)*Len + J, which is bounded by declaring Count and Len with small ranged subtypes and a buffer sized for their product, so every index check follows from the types.
- **length**: The result length is Count*Len, which the buffer capacity covers by construction, and the slice printed is the buffer's own prefix of that length.

## Language surface recorded by this assessment

Integers, ranged subtypes, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the repeated strings with Put_Line.

Assessed on 2026-10-15 against page revision 411533 of the [task](https://rosettacode.org/wiki/Repeat_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
