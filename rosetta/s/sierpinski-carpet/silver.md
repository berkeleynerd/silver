# Sierpinski carpet

**Candidate: proofs likely to discharge automatically.** Every index and value is bounded by static ranges and for loops over constant bounds, so all run-time checks follow from types and no loop-carried fact needs an invariant. The only added surface is integers, mod/div, a character buffer and for/procedure support, all with routine checks.

Position 500 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program fixes order 3 (size 27), loops over each row R and column C in 0..26 with for loops, and decides each cell without any array: copy R and C into local variables and repeatedly test whether both have remainder 1 when divided by 3 (a hole), stepping both by division by 3 for a fixed three iterations. Each row is built in a fixed 27-character String variable by assigning a Character per column, then printed with Silver_IO.Put_Line, so no recursion, no stored pattern array and no unbounded loop is needed. About 35 lines.

## Proof obligations to watch

- **index**: Cell tests use mod 3 on digits of row and column, with indexes taken from for-loop ranges over the fixed 27 by 27 bounds, so no index check can fail.
- **overflow**: Row, column and quotient values stay within a declared range 0..26, so the arithmetic is bounded by types.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, string indexing, string building, for loops, while loops, procedures, Put without a newline, arrays and Boolean objects.

## External effects

- **console output** (allowed): Prints the carpet rows to standard output, one line per row.

Assessed on 2026-10-15 against page revision 413410 of the [task](https://rosettacode.org/wiki/Sierpinski_carpet) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
