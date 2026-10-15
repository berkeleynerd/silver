# Poker hand analyser

**Candidate: proofs plausibly discharge automatically.** All indexes and counters can be bounded by ranged types or by guards placed immediately before use, and no recursion or functions with while loops are needed, so no annotation is required, though the parser's loop-carried cursor and counters make the program shape matter.

Position 1148 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The nine example hands are embedded as fixed-capacity strings and parsed by a procedure into five face and suit values held in small ranged-subtype arrays, with any malformed card, wrong card count or duplicate card giving the visible outcome invalid. Classification uses face-count and suit-count arrays filled by for loops, then tests for four, three plus pair, flush, straight (including ace low) and pairs through plain if statements. Each result is printed with ASCII suit letters and the extra-credit jokers and Unicode glyphs are left out. About 170 lines.

## Proof obligations to watch

- **index**: Tokenising a bounded hand string with a loop-carried cursor needs an explicit bound guard before every character read, which the program places just before each access.
- **overflow**: Per-face and per-suit counters are loop-carried and would fail a range check after the first iteration, so each increment is guarded by a test against the counter's maximum and a hit rejects the hand as invalid.
- **range**: Face and suit values derived from parsed characters are converted to ranged subtypes only after a membership-style comparison that rejects anything outside 2..14 or the four suits.
- **termination**: The tokenising loop is a while loop kept inside a procedure so no termination check applies, and everything else uses for loops.

## Language surface beyond today's Silver

Ranged subtypes, characters, arrays, for loops, while loops, procedures, functions, Boolean objects, string indexing, case statements, text parsing and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded hand and its rank, one line per hand.

Assessed on 2026-10-15 against page revision 414406 of the [task](https://rosettacode.org/wiki/Poker_hand_analyser) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
