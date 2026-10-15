# Set, the card game

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges, for-loop indexes and constant divisors, with no recursion, no loop-carried unbounded value and no heap use, so proofs should discharge without annotations. The only careful shape is keeping the generator state in a bounded subtype.

Position 804 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Cards are integers 0..80 whose four base-3 digits encode number, symbol, colour and shading, held in a constrained 81-element pack array that a fixed-seed linear congruential generator shuffles with a Fisher-Yates for loop. A fixed hand size of 12 is taken from the front, printed with case statements and Put/Put_Line pieces, then three nested for loops test every triple by checking that each digit sum is divisible by 3 and print the matching sets. All loops are for loops with static bounds inside procedures or simple functions, so no variants or invariants are needed. About 110 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator's multiply-and-mod step stays inside Integer because the state is a subtype bounded to 0..65536 and the multiplier is a small literal.
- **index**: Shuffle swaps index with Seed mod (I+1), which is provably within 0..I for a for-loop index over the array's own range, and set-search indexes come from nested for loops with the next index starting at the previous plus one.
- **range**: Card digit extraction divides a Card subtype 0..80 by constants 1, 3, 9 and 27 and takes mod 3, so each result lies in 0..2 and indexes the attribute cases directly.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, case statements, procedures, functions, Put without a newline, 'Image of scalars and Boolean objects.

## External effects

- **console output** (allowed): Prints the dealt cards and each identified set as text lines.

Assessed on 2026-10-15 against page revision 415120 of the [task](https://rosettacode.org/wiki/Set,_the_card_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
