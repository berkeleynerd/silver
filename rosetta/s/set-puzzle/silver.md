# Set puzzle

**Candidate: proofs plausibly discharge automatically.** Everything is small bounded integer arithmetic over typed 0..2 features and fixed-size arrays, with while loops confined to procedures and capped by counters, so proofs should discharge with careful shaping but no annotations.

Position 858 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Cards are arrays of four features each in a 0..2 subtype, held in a fixed array of 9 (or 12) slots, dealt by drawing from a deterministic LCG with a seed constant and redrawing duplicates under an attempt cap. For each pair (I, J) the third completing card is computed per feature, located by a for-loop scan, and counted or printed when its index exceeds both; the deal repeats until the set count equals 4 (or 6), then names are printed via constant string tables of equal-length entries. Mode is fixed by embedded constants (basic then advanced), with no input read. About 170 lines.

## Proof obligations to watch

- **overflow**: The LCG state is kept in a bounded range type with a small modulus so multiplier times state fits in Integer, and mod re-bounds it each step.
- **index**: Card features are subtype 0..2 and card ids 0..80, so the computed third card (3 - a - b mod 3) and its lookup index stay in range by type and by guarding the Locate result before use.
- **termination**: Redraw and redeal loops live in procedures (no termination check) and are bounded by an explicit attempt counter with a visible 'no deal found' outcome when the cap is hit.
- **range**: Loop-carried card counts and set counters are typed with capped ranges and guarded before increments, because no invariant can be written.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, case statements, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the dealt cards and the sets found, one line each, via Put_Line.

Assessed on 2026-10-15 against page revision 414465 of the [task](https://rosettacode.org/wiki/Set_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
