# Snake and ladder

**Candidate: proofs plausibly discharge automatically.** All indices, sums and generator updates are bounded by subtypes and guards placed right before use, and the loops live in procedures so no variants are needed, but the several loop-carried values (positions, generator state) need careful typing.

Position 925 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The board is a constant array of 100 destination squares (identity except at the 16 snake and ladder squares), and two player positions are kept in an array of Square subtype. A deterministic LCG feeds a procedure that plays the computer's and the simulated human's turns in alternation (the human's move is also scripted, since stdin is optional), with the roll-again-on-six logic in an inner while loop and a bounded turn cap. Every step is printed with Put_Line and Image text, and moves past 100 are rejected with a printed message instead of being clamped. About 110 lines.

## Proof obligations to watch

- **termination**: The game loop and the roll-again loop are while loops inside procedures, which get no termination check, and a fixed turn cap guarantees an outcome for every path.
- **range**: The deterministic generator state and its reduction to a 1..6 roll use a modular LCG or a bounded range, so the generator is kept in a subtype and updated with a guard so that intermediate products cannot overflow.
- **index**: The board is a table indexed by squares 1..100 whose destination values are static and typed as squares, and the position stays in range because moves past 100 are rejected before adding.
- **overflow**: The position plus roll sum is bounded by the Square subtype (at most 100) plus 6, which fits easily in Integer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, 'Image of scalars, string building, for loops, while loops, procedures, functions, conditional expressions and Put without a newline.

## External effects

- **console output** (allowed): The game prints each roll, move, snake or ladder event and the winner as text.

Assessed on 2026-10-15 against page revision 413032 of the [task](https://rosettacode.org/wiki/Snake_and_ladder) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
