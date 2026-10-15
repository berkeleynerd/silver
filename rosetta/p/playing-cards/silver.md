# Playing cards

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded array index types, for-loop ranges and a range-typed LCG state, with only for loops and no recursion, so no annotation is needed; the empty-deck case is a guarded visible outcome rather than an exception.

Position 1175 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Declare enumerations Pips (Two..Ace) and Suits, a Card record, and a Deck record holding a 52-element array of Cards plus a Next_Card counter in 1..53. Procedures New_Deck (nested for loops), Shuffle (Fisher-Yates for loop with a deterministic LCG state of a bounded range type and a swap index derived by mod), Deal (if Next_Card is above 52 print a visible deck-empty message and leave the deck unchanged, else return the card and advance) and Print (for loop from Next_Card to 52 using 'Image) are called from Main, which prints the deck, shuffles, deals a few cards and prints again. About 90 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplies a seed bounded to a 31-bit range type by a constant, so the product stays under 2**63 and the type range discharges it without any loop-carried reasoning.
- **index**: The Fisher-Yates swap index is computed as a generator value mod the remaining count plus the loop index, which the provers show in range from the mod bound and the loop index range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, enumerations, arrays, records, for loops, procedures, functions, Boolean objects, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the new, shuffled and post-deal deck contents as lines through Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413403 of the [task](https://rosettacode.org/wiki/Playing_cards) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
