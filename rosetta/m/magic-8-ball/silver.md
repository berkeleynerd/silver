# Magic 8-ball

**Candidate: proofs likely to discharge automatically.** Every check follows from the 0..19 subtype, the loop over the buffer's own range and the bounded multiply-add, with no loop-carried value needing an invariant; the only new work is stdin line reading and a case statement over 20 literals.

Position 1214 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program prints a welcome and a prompt, reads one question line into a bounded fixed-capacity buffer with a length (an over-long or empty line takes a specified rejection message), then folds the question's characters with a for loop into a hash in a 0..19 subtype using (H * 31 + Character'Pos) mod 20. A case statement over that subtype prints one of the 20 classic answers with Put_Line, replacing system randomness with a deterministic generator. About 70 lines.

## Proof obligations to watch

- **overflow**: The hash step multiplies a value of subtype 0..19 by a small constant and adds a Character position (at most 255), so the result fits Integer and a mod 20 returns it to the subtype, which types alone establish.
- **index**: The for loop runs over the question buffer's own index range and the answer selector has subtype 0..19, so the case statement is complete and every index is in range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string indexing, case statements, for loops, procedures and standard input.

## External effects

- **console output** (allowed): Prints the welcome text, the prompt and the chosen answer.
- **standard input** (allowed): Reads the user's question as one line from standard input.

Assessed on 2026-10-15 against page revision 414909 of the [task](https://rosettacode.org/wiki/Magic_8-ball) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
