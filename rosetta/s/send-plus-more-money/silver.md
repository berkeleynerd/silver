# SEND + MORE = MONEY

**Candidate: proofs likely to discharge automatically.** Every check follows from the 0..9 digit subtype bounds and for-loop indexes, with no accumulators, recursion or while loops, so the proofs should discharge automatically. The only growth needed is ranged subtypes, for loops, integer arithmetic and character conversion for output.

Position 444 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Declare subtype Digit is Integer range 0 .. 9 and enumerate S, E, N, D, O, R, Y (and M, with leading letters starting at 1) with nested for loops in the Main procedure, testing pairwise distinctness with and then comparisons and then the equation SEND + MORE = MONEY. On a match, build each output row from digit Characters by concatenation into fixed-length String variables and print them with Put_Line. All arithmetic operands are range-typed digits, so no loop invariants are needed, and loop-carried state is just the loop indexes. About 60 lines.

## Proof obligations to watch

- **overflow**: The sums 1000*S+100*E+10*N+D and the MONEY value are over Digit-typed operands bounded 0..9, so every result is at most 99999 and fits Integer, and the provers handle this linear bound routinely.
- **range**: Converting a Digit to a Character via 48 + digit stays within Character'Val's 0..255 range because the digit subtype is statically 0..9.

## Language surface recorded by this assessment

Ranged subtypes, integers, characters, Boolean objects, for loops, string building and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the puzzle and the found solution lines with Put_Line.

Assessed on 2026-10-15 against page revision 408511 of the [task](https://rosettacode.org/wiki/SEND_%2B_MORE_%3D_MONEY) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
