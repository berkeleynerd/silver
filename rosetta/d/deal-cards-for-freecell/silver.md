# Deal cards for FreeCell

**Candidate: proofs likely to discharge automatically.** Every check follows from the declared state range, the for-loop indexes and the divisor 52 - i, with no loop-carried value needing a guard beyond its type, so the proofs should discharge without annotations.

Position 515 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Represent the deck as an array of 52 integers 0..51 and the seed and state as a range type 0..2**31-1, with the LCG step computed in a wider 64-bit integer range and reduced by mod 2**31. A procedure Deal(Num) loops i in 0..51, takes pick = (state / 65536) mod (52 - i), emits the card's rank and suit characters from constant lookup strings, moves the last live card into the picked slot, and ends a row of output after every eighth card. Main calls Deal with the embedded numbers 1 and 617 and prints a blank line between them. About 55 lines.

## Proof obligations to watch

- **overflow**: The LCG step multiplies a state in 0..2**31-1 by 214013 and adds 2531011, which stays below 2**50 in a 64-bit integer type, so the bound follows from the declared ranges alone.
- **range**: The state is carried through the loop but is reduced with mod 2**31 into its declared range type each step, so no invariant is needed.
- **index**: The pick is the random value mod (52 - i) with i a for-loop index over 0..51, so the divisor is at least 1 and the pick is below the shrinking length; deck(51 - i) is also within 0..51.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the two embedded deals (numbers 1 and 617) as rows of eight two-character cards.

Assessed on 2026-10-15 against page revision 412737 of the [task](https://rosettacode.org/wiki/Deal_cards_for_FreeCell) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
