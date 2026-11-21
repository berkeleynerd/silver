# Blackjack strategy

**Candidate: proofs plausibly discharge automatically.** Everything can be bounded by types (single deck, at most a handful of cards per hand, 365*50 hands) and the recursion is replaced by an explicit stack in procedures, but float probability accumulation, the stack-index guards and split and double rule handling make the proof shape demanding though annotation-free.

Position 1198 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Cards are ranks 1..10 held as a 10-element array of remaining counts; hand totals, soft flags and pair status are small ranged integers, and dealer and player continuations are enumerated by an iterative depth-first search over an explicit bounded stack in procedures, accumulating exact-as-floating win, lose and push probabilities per dealer upcard. The hard, soft and pair tables are stored in 2D arrays of an action enumeration chosen by comparing expected values against a double threshold, printed as text lines, and then a deterministic LCG deals 50 hands for each of 365 days using the table to track daily and yearly totals, biggest win and biggest loss. About 450 lines.

## Proof obligations to watch

- **floating point**: Win and loss probabilities are accumulated through loops, so they use a wide ranged Long_Float subtype and divide only after guarding that the remaining card total is positive, so no float overflow or range check can fail.
- **index**: The explicit depth-first stack replacing recursion needs a guard before every push and pop on the stack index, and a full stack must give a specified rejection rather than a silent change of result.
- **overflow**: Money totals over 365 days of 50 hands, and the generator state, are held in ranged integers or modular types sized well within 64 bits so the arithmetic is bounded by the types.
- **termination**: Enumeration and simulation loops live in procedures (no termination check) and the only functions use for loops over fixed ranges.
- **division**: Every probability division by the cards remaining is guarded by a test that the count is nonzero, which holds for a single deck since at most 11 cards are drawn from 52.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, enumerations, floating point, arrays, multidimensional arrays, records, string building, 'Image of scalars, floating-point images, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The strategy tables, per-hand results and the yearly win/loss summary are printed as text lines.

Assessed on 2026-10-15 against page revision 390173 of the [task](https://rosettacode.org/wiki/Blackjack_strategy) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
