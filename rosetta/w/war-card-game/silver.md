# War card game

**Candidate: proofs plausibly discharge automatically.** All indexing and counts can be made safe with range types, mod and explicit guards in procedures, and the only unbounded behavior (endless wars) is cut off by a documented round cap with a visible outcome; the arithmetic is small and linear apart from the LCG, so no annotation is needed.

Position 642 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Cards are ranks 2..14 in a 52-element array, shuffled with a Fisher-Yates pass driven by a deterministic LCG seed and dealt 26 each into two ring-buffer hand records (array, head, count) plus a bounded war pile. A procedure plays a capped number of rounds in a while loop: compare top cards (ace high), collect to the winner in play order, and on ties run a war loop that draws up to two cards per player, using each player's last card if short, with every draw and add guarded by a count test. Each round prints a line via Put_Line with Put and integer image, ending with the winner or an undecided message at the round cap. About 170 lines.

## Proof obligations to watch

- **index**: Ring-buffer head and tail positions are loop-carried, so each is reduced with mod the capacity (and typed 0..51) immediately before indexing to discharge without an invariant.
- **range**: Hand and war-pile counts cannot be proved at most 52 without an invariant, so every add is guarded by a count-below-capacity test that leads to a visible internal-error message and stop, not a silent change.
- **overflow**: The LCG shuffle seed update is nonlinear (multiply then mod), so the seed gets a small range type and the product stays far below Integer'Last.
- **termination**: War can in principle cycle forever, so the game runs in a procedure with a documented cap on rounds and a specified 'undecided after N rounds' outcome rather than a while loop in a function.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): The program prints the dealt hands, each round's outcome, wars and the final winner to standard output.

Assessed on 2026-10-15 against page revision 414578 of the [task](https://rosettacode.org/wiki/War_card_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
