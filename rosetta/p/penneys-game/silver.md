# Penney's game

**Candidate: proofs likely to discharge automatically.** Every check follows from fixed 3-character strings, a ranged generator state and an explicit length and character guard on the input line, and the only unbounded loops are while loops inside procedures. It needs several new features (stdin lines, character indexing, procedures, while loops, Put) but no annotation or recursion.

Position 1228 in the [progression](../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Sequences are fixed 3-character Strings of H and T, and a small deterministic linear congruential generator over a ranged subtype (fixed seed) supplies the coin tosses, who goes first and the computer's random choice. The computer's optimum reply as second player is built from the player's characters (the opposite of the middle one, then the first two), the player's line is read in a procedure with a validation loop that re-prompts on bad input and rejects on end of input, and a while loop in a procedure shifts a 3-character window of tosses, printing each toss until the window equals either sequence. About 110 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplication is discharged by declaring the state as a range below 2**31 so the product fits in 64 bits before the mod.
- **termination**: The input re-prompt loop and the toss-until-win loop are while loops inside procedures, which get no termination check, and end of input is handled by an explicit rejection so the prompt loop cannot spin.
- **length**: The input line is checked for length 3 and only H or T characters before indexing or copying into the fixed three-character sequence.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, string building, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prompts, the computer's sequence, the successive coin tosses and the winner are printed.
- **standard input** (allowed): The human opponent's three-letter sequence is read as a line from standard input, with end of input needing a specified outcome.

Assessed on 2026-10-15 against page revision 412269 of the [task](https://rosettacode.org/wiki/Penney's_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
