# 21 game

**Candidate: proofs likely to discharge automatically.** Every check follows from a 0..21 subtype, a 1..3 amount validated from input, and a guard placed just before the addition, and the only loop is a while loop in a procedure. The task's random option is optional, so a deterministic computer strategy and a user-chosen first player satisfy it with no annotations needed.

Position 1214 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

A Main procedure holds a Total of subtype 0..21 and a two-value Player enumeration, reads the first-player choice from one stdin line, then loops with while until someone reaches 21 or the user quits ('0', or end of input). The human line is validated as 1, 2 or 3 (otherwise an error message and re-prompt, including a message when the amount would exceed 21), and the computer plays a deterministic move of (21 - Total) mod 4, or 1 if that is 0, clamped by a guard to the remaining distance; after each addition the program prints the total with 'Image-based text and announces the winner. About 80 lines.

## Proof obligations to watch

- **range**: Total is a 0..21 subtype and the sum is computed only after an explicit guard that Total plus the chosen amount is at most 21, with an over-limit choice answered by an error message and re-prompt.
- **termination**: The turn loop is a while loop inside a procedure, which gets no termination check, and it ends on a win, a quit command or end of input.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, enumerations, case statements, while loops, procedures, 'Image of scalars, Put without a newline, standard input and string building.

## External effects

- **console output** (allowed): Prompts, error messages, the running total and the winner announcement are printed.
- **standard input** (allowed): The first-player choice and each move or quit command are read from standard input, with end of input treated as quit.

Assessed on 2026-10-15 against page revision 412079 of the [task](https://rosettacode.org/wiki/21_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
