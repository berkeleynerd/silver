# Mind boggling card trick

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, range-typed counters and guards just before pile stores and mod divisors, but several loop-carried values (pile counts, generator state, success count) need careful typing and guards, so discharge depends on program shape.

Position 168 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Represent the deck as a 52-element array of card indices (red when index is below 26), shuffled by Fisher-Yates driven by a deterministic LCG held in a range-bounded integer; deal pairs from the deck into fixed 26-slot red and black pile arrays with counts guarded before each store. Pick X by the LCG after guarding non-empty piles, partially shuffle each pile so the first X are a random choice, swap those X slots between piles, then count black in the black pile and red in the red pile and compare. Repeat in a for loop for a fixed number of trials in a procedure, accumulating a range-bounded success count, and print it with Put_Line and 'Image. About 110 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator state is a range-bounded 64-bit-safe subtype with a small multiplier and a mod after each step, so the product cannot overflow.
- **index**: Pile counts are loop-carried and appended to inside a for loop, so each append is guarded by a test against pile capacity 26 just before the store, with the failure outcome being a visible rejection message.
- **range**: The swap size X is drawn as 1 + (random mod Min(Red_Count, Black_Count)) after a guard that both piles are non-empty, and the pile counts are range-typed so the arithmetic stays in bounds.
- **division**: The mod divisors (shuffle bound and pile minimum) are protected by explicit guards that they are positive.
- **initialization**: All arrays are fully initialized by aggregates or fill loops before use, which flow analysis can see.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the count of trials where the assertion held, using Put_Line.

Assessed on 2026-10-15 against page revision 413787 of the [task](https://rosettacode.org/wiki/Mind_boggling_card_trick) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
