# Card shuffles

**Candidate: proofs plausibly discharge automatically.** All arithmetic is small bounded integer work on a fixed 52-element array, so checks reduce to types and guards before each index, but loop-carried cursors need careful shaping without invariants.

Position 468 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The deck is a constant-size array of 52 card indices with a second output array, and a seeded LCG in a procedure supplies pseudo-random numbers. Riffle splits at a fixed point and merges by comparing a random draw against the remaining pile proportions, guarding both cursors; overhand repeatedly takes a random group of 1 to a fifth of the remaining cards and places it on the new pile, using a while loop in a procedure. Each shuffle runs for a fixed n iterations and the result is printed as card-name text lines, with a simple built-in-style Fisher-Yates comparison optional. About 110 lines.

## Proof obligations to watch

- **index**: Pile cursors in the riffle merge are loop-carried, so each array access is guarded by an explicit bound check just before use, with the pile sizes fixed by the constant deck size.
- **overflow**: The deterministic LCG state is kept in a modular or range-bounded type and reduced with mod before each use, so no arithmetic overflows.
- **termination**: The overhand while loop lives in a procedure, which gets no termination check, and each pass takes at least one card so it ends anyway.
- **range**: Remaining-card counts are loop-carried and must stay inside 0..52 and be guarded before subtraction, and the group size is clamped to at least 1 and at most the remaining count.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the shuffled deck orderings as text lines.

Assessed on 2026-10-15 against page revision 414103 of the [task](https://rosettacode.org/wiki/Card_shuffles) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
