# Combinations

**Candidate: proofs plausibly discharge automatically.** Every check is an array index from a for-loop range or an increment of a small ranged value under a just-before guard, and the loop lives in a procedure so no variant is needed; the shape needs careful guards on loop-carried element values, so it is plausible rather than likely.

Position 540 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed m=3 and n=5 as constants, hold the combination in a three-element array of a 0..4 subtype, and fill it with 0,1,2 in a first for loop. A while loop in Main prints the current combination by writing digit characters into a fixed 6-character line buffer and calling Put_Line, then finds the rightmost position whose value is below its maximum (2+I) with a reverse for loop, increments it and resets the later positions to predecessor plus one under guards, and clears a Done flag when no position can advance. About 55 lines.

## Proof obligations to watch

- **range**: Incrementing an element of a 0..4 array and setting successors to previous plus one are loop-carried values, so each increment is placed under an explicit guard that the predecessor is below 4, with a visible stop outcome otherwise.
- **index**: The pivot search runs a for loop in reverse over the array's own range 1..3 and the inner for loop starts at I+1 within that range, so indices follow from loop bounds.
- **termination**: The outer enumeration is a while loop confined to the Main procedure, which gets no termination check, so no variant is needed.
- **overflow**: Digit-to-Character conversion uses a value bounded by the 0..4 subtype so 48 plus the digit stays within Character range.

## Language surface recorded by this assessment

Ranged subtypes, arrays, characters, for loops, while loops, string indexing, string building, integers, Boolean objects and procedures.

## External effects

- **console output** (allowed): Prints each combination as a line of space-separated digits.

Assessed on 2026-10-15 against page revision 411604 of the [task](https://rosettacode.org/wiki/Combinations) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
