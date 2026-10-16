# Set right-adjacent bits

**Candidate: proofs likely to discharge automatically.** Every check follows from array ranges, for-loop indexes and a counter typed 0 .. 10_000 whose only decrement is guarded, with no while loops, recursion or nonlinear arithmetic, so proofs should discharge without annotations.

Position 537 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Bits are held in a fixed-capacity Boolean array indexed 1 .. 10_000 with a separate width subtype, filled from an embedded '0'/'1' string with a guard that rejects any other character or a width above capacity. A single left-to-right for loop carries a remaining-fill counter (reset to n at each set bit, decremented under a guard when positive) and writes the result bit, avoiding the repeated shift-and-or of the original. A procedure prints the n and width header, then the input and result rows as aligned characters for the four nibble cases and the four 66-bit cases. About 85 lines.

## Proof obligations to watch

- **range**: The run counter is a subtype 0 .. 10_000 that is only decremented under an explicit guard that it is greater than zero, so the decrement check discharges from the guard and the type range.
- **index**: All indexing is by for loops over the bit array's own range with a declared 10_000-bit capacity, and the 66-bit example is checked against the capacity by an explicit guard before copying.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each case header, input bits and result bits to standard output.

Assessed on 2026-10-15 against page revision 413910 of the [task](https://rosettacode.org/wiki/Set_right-adjacent_bits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
