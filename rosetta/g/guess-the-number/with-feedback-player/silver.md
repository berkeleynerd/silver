# Guess the number/With feedback (player)

**Candidate: proofs likely to discharge automatically.** Every check follows from the ranged subtype of Low and High and a guard on Low <= High before each midpoint, and termination needs no variant because the loop is a bounded for loop in a procedure. The new needs are standard-input line reading, integer-to-text output and a few basic constructs, so the outlook is likely.

Position 1211 in the [progression](../../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program embeds the limits 1 and 100 and keeps Low and High in a small ranged subtype. A bounded for loop in the Main procedure guesses the midpoint, prints it, reads one feedback line from standard input, and exits on correct, sets High below the guess on lower, and sets Low above the guess on higher. Unknown feedback and contradictory feedback (Low greater than High) each print a specified message and end the game. About 55 lines.

## Proof obligations to watch

- **overflow**: Low and High are loop-carried, so the midpoint and the Guess + 1 and Guess - 1 updates are discharged by declaring them in a small subtype (such as 0 .. 101) and checking Low <= High just before computing the guess.
- **termination**: The binary search runs in a procedure as a for loop over a fixed 1 .. 100 iteration count with an exit when, so no variant is required.
- **length**: The input line is read into a bounded buffer with an explicit length, and the comparison against the three feedback words is guarded by that length.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, procedures, while loops, for loops, standard input, Put without a newline, 'Image of scalars, string building and string indexing.

## External effects

- **console output** (allowed): Prints the prompt, each guess and the final outcome.
- **standard input** (allowed): Reads the scorer's feedback line (lower, higher or correct) after each guess.

Assessed on 2026-10-15 against page revision 412553 of the [task](https://rosettacode.org/wiki/Guess_the_number/With_feedback_%28player%29) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
