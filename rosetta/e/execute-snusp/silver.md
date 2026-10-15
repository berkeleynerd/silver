# Execute SNUSP

**Candidate: proofs plausibly discharge automatically.** Every index and counter is range-typed or guarded just before use, cells wrap by a modular type, and the loop sits in a procedure with a step limit, so no annotation is needed, though careful guard placement across the loop-carried positions is required.

Position 1309 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

The SNUSP source is embedded as a constant 2D Character grid of fixed rows and columns padded with spaces, with variables for row, column, a four-valued direction enumeration, a modular Byte tape array with a tape index, and a bounded output buffer. A while loop in a procedure fetches the character at the current position and a case statement implements the core instructions ($ \ / + - < > . ! ? and the comma yielding 0 since no input is read), then advances the pointer after a bounds guard; any bound, step-limit or buffer limit ends the run with a printed status line. The collected output is printed at the end with Put_Line. About 130 lines.

## Proof obligations to watch

- **index**: Row and column of the instruction pointer and the tape pointer change inside a while loop, so each move is guarded by a bounds test just before the move and an out-of-range move halts with a visible status.
- **overflow**: Cell increments and decrements use a modular Byte type so wraparound is the specified cell behavior, and the step and output counters are checked against their limits before being incremented.
- **termination**: The interpreter loop lives in a procedure, which gets no termination check, and an explicit step limit gives a specified 'step limit reached' outcome for non-terminating SNUSP programs.
- **length**: The output buffer is a fixed-capacity string with a count, and each '.' is guarded by a capacity test that halts with a visible 'output full' status instead of dropping characters.

## Language surface beyond today's Silver

Ranged subtypes, integers, characters, enumerations, arrays, multidimensional arrays, modular types, string indexing, string building, Boolean objects, case statements, while loops, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the interpreted program's output buffer and any halt status with Put_Line.

Assessed on 2026-10-15 against page revision 412778 of the [task](https://rosettacode.org/wiki/Execute_SNUSP) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
