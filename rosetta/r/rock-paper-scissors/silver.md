# Rock-paper-scissors

**Candidate: proofs likely to discharge automatically.** Everything is small enumerations, bounded counters and a procedure-hosted while loop with explicit guards, so all checks follow from types and guards, though the new stdin line reading and enumeration/array surface must exist first.

Position 1218 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

A Choice enumeration (Rock, Paper, Scissors) indexes a count array of bounded subtype initialised to 1 each, and a deterministic LCG, held as a bounded integer state advanced with mod, drives a weighted pick of the computer's counter-move by comparing a draw in 0..total-1 against cumulative counts. The main procedure loops while input remains and rounds are below a fixed maximum, reading a line, mapping "r"/"p"/"s" (either case) to a Choice, "q" or end of input to quit, and printing a specified message for any other line before re-prompting. Counts are only incremented when below their cap and the winner is decided by a case statement, with scores printed at the end via 'Image. About 110 lines.

## Proof obligations to watch

- **overflow**: The choice counts, scores and the generator state are loop-carried, so they use bounded subtypes with an explicit guard before each increment and a generator step computed with mod on operands whose types keep the product in range.
- **termination**: The round loop is a while loop inside a procedure, which gets no termination check, and it is also capped by a fixed maximum round count.
- **index**: The choice enumeration indexes the count arrays directly, and the weighted pick is a chain of comparisons that always ends in a defined branch.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, string indexing, 'Image of scalars, case statements, for loops, while loops, procedures, functions, standard input and Put without a newline.

## External effects

- **console output** (allowed): Prompts, the computer's choice, each round's result and the final score are printed.
- **standard input** (allowed): The operator's r/p/s/q choice is read one line at a time, with end of input treated as quitting.

Assessed on 2026-10-15 against page revision 414889 of the [task](https://rosettacode.org/wiki/Rock-paper-scissors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
