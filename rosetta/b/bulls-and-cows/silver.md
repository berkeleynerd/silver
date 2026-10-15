# Bulls and cows

**Candidate: proofs plausibly discharge automatically.** All indexing, arithmetic and validation follow from small constant ranges and guards placed just before use, and the only loop-carried counters are small and guardable, so no annotation is needed; the program does depend on a stdin-line operation with a defined end-of-input outcome and on bounded-buffer string handling that Silver lacks today.

Position 1237 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Fixed-seed linear congruential generator over a ranged state picks four distinct digits from a 9-element array by removing each chosen digit, stored in a 1..4 array of digit values. A while loop in the Main procedure reads a line through an admitted stdin operation, rejects it with a message unless it has length 4, all characters are in '1'..'9' and no two are equal, then counts bulls and cows with nested for loops over 1..4 and prints the score or a win message. About 80 lines.

## Proof obligations to watch

- **overflow**: The bull and cow counters are loop-carried in nested loops, so each increment sits behind a guard against the counter's declared maximum, or the counts are derived from per-position Boolean flags, since no invariant can be written.
- **overflow**: The deterministic generator keeps its state in a ranged subtype and uses a multiply-add followed by mod, with constants chosen so the product fits in 64 bits.
- **index**: The secret digit is picked by state mod remaining-size plus one, which lies within the 1..9 digit array, and removal is done by a for-loop shifting elements over the array's own range.
- **termination**: The guess loop is a while loop inside a procedure, so no termination check applies, and end of input must exit the loop with a specified outcome.
- **length**: The input line must be checked to have length exactly 4 before indexing, with the line read into a bounded buffer whose overlong input is rejected as malformed.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, Boolean objects, Put without a newline, standard input and text parsing.

## External effects

- **console output** (allowed): Prompts, rejection messages and bull/cow scores are printed to standard output.
- **standard input** (allowed): Each guess is read as a line from standard input, with a specified outcome at end of input.

Assessed on 2026-10-15 against page revision 412081 of the [task](https://rosettacode.org/wiki/Bulls_and_cows) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
