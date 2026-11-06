# Summarize and say sequence

**Candidate: proofs plausibly discharge automatically.** All checks come from ranged subtypes, for-loop indexes over fixed arrays and capacity guards before buffer writes, and the repeat-detection loop lives in a procedure so no variant is needed, but loop-carried buffer positions need careful guard placement.

Position 735 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Each term is a bounded digit buffer (a record holding a fixed-capacity Character array plus a length) and the history is a fixed array of 64 such terms; a procedure counts digits, writes count then digit from 9 down to 0 into the next buffer, and compares it with every history entry in an index-bounded for loop. The main loop runs over seeds 1..999_999 with digits extracted by mod and /, tracks the best iteration count and collects the best seeds in a bounded list, then replays the winning seed and prints each term with Put_Line. Every write is guarded by a capacity check that reports overflow visibly, and loop counters use ranged subtypes. About 150 lines.

## Proof obligations to watch

- **index**: Writing a term's digits into a bounded buffer and appending to the term history needs explicit capacity guards before each write, with an overflow visibly reported rather than silently truncating.
- **overflow**: Loop-carried length and position counters are declared with ranged subtypes and incremented only after a guard, because without invariants only type ranges are known after the first iteration.
- **termination**: The sequence-until-repeat loop is a while loop inside a procedure, so no termination check is generated, and a history-capacity guard ends it with a visible outcome anyway.
- **other**: Counts of 10 or more would widen a term beyond two characters per digit, so the buffer capacity guard must cover this case and report overflow rather than assume single-digit counts.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, string building, 'Image of scalars, Put without a newline, Boolean objects and functions.

## External effects

- **console output** (allowed): Prints the iteration count, the winning seeds and the sequence terms as text lines.

Assessed on 2026-10-15 against page revision 415087 of the [task](https://rosettacode.org/wiki/Summarize_and_say_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
