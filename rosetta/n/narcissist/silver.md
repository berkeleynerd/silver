# Narcissist

**Candidate: proofs plausibly discharge automatically.** Every check follows from a static source-length constant, guards before each buffer access and a saturating counter, but the quine construction with computed slice bounds and character-level stdin reading make the program shape delicate, so discharge is plausible rather than routine.

Position 1223 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program holds its own source as a quine-style template string constant, expands it into a fixed-size buffer of the program's exact length by inserting the quoted template, and records the source length as a constant. It then reads standard input one character at a time in a procedure, comparing each character with the expected one and tracking a mismatch flag and a saturating count, so input of any length is handled without a growing buffer. At end of input it prints accept only if there was no mismatch and the count equals the source length, otherwise reject. About 45 lines.

## Proof obligations to watch

- **index**: The reader compares each input character against a source position guarded by a bound check against the source length, and extra input is only counted so the index never exceeds its range.
- **length**: The quine template is expanded into a fixed-capacity source buffer whose size is a static constant, so slice lengths and concatenation sizes follow from the constant's known length.
- **termination**: The input-reading while loop sits in a procedure, which gets no termination check, and every other loop is a for loop.
- **overflow**: The count of input characters is a saturating counter capped at one more than the source length, so it cannot overflow however long the input is.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, arrays, for loops, while loops, procedures, standard input and Put without a newline.

## External effects

- **standard input** (allowed): The program reads the candidate source text character by character from standard input until end of input.
- **console output** (allowed): It prints accept or reject, which is distinguishable from any not-finished state because the program always halts.

Assessed on 2026-10-15 against page revision 413800 of the [task](https://rosettacode.org/wiki/Narcissist) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
