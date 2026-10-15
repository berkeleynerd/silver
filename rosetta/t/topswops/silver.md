# Topswops

**Candidate: proofs plausibly discharge automatically.** All checks come from the array's declared index range, card subtype and explicit guards before each reversal or scan, and loops sit in procedures so no variants are needed, but several loop-carried indexes and the 3.6 million-permutation run for n=10 make the discharge depend on careful program shape.

Position 271 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Represent a deal as an array (1..10) of cards in subtype 1..10 with a current length n, enumerate all permutations of 1..n iteratively with a lexicographic next-permutation while loop, and for each play the game with a while loop that reverses the first m cards with a for loop after guarding m <= n. Track the maximum swap count per n in a procedure, then print each row with Put_Line using bounded string building of the integer images. About 90 lines.

## Proof obligations to watch

- **index**: Reversal and next-permutation indexes are loop-carried, so each is guarded (card value at most n, scan index at least 1) or typed to the array's 1..10 index range just before use.
- **range**: Card values are stored in a subtype 1..10 and swaps assign only values read from the same array, so range checks follow from types, but the reversal bound m must be guarded against n before the loop.
- **overflow**: The swap counter and per-n maximum are typed with a range wide enough (Natural up to a few hundred) and the counter is incremented in a procedure under a cap guard, since no invariant can bound it.
- **termination**: The play-until-1-on-top loop and the permutation-advance loop are while loops confined to procedures, which get no termination check, and no function contains a loop.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the table of n versus topswops(n) for n in 1..10.

Assessed on 2026-10-15 against page revision 414674 of the [task](https://rosettacode.org/wiki/Topswops) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
