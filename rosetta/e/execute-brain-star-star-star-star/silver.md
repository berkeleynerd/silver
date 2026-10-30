# Execute Brain\*\*\*\*

**Candidate: proofs plausibly discharge automatically.** Every index, range and counter check can be discharged by a guard placed just before use, and no function-level loops or annotations are needed, but several loop-carried values (instruction pointer, tape pointer, bracket depth, step count) need careful guards. The step limit and explicit bounds keep the interpreter faithful for the tasks's required instructions while remaining provable.

Position 1227 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The Brainf*** program is an embedded constant String, interpreted over a fixed-size array of 0..255 cells (for example 30000) with an instruction index and a tape pointer. A while loop in a procedure dispatches each command with a case statement, scanning forward or back with a depth counter to find matching brackets, and any pointer move out of bounds, unmatched bracket, or exceeded step limit prints a rejection message and stops. Output uses Put with Character'Val of the cell, and input reads a character from stdin, storing 0 at end of input. About 110 lines.

## Proof obligations to watch

- **index**: The tape pointer and instruction pointer are loop-carried, so each is guarded just before every use (a move off either tape end ends the run with a visible error message).
- **range**: Cells are a 0..255 subtype with explicit wrap-around branches on + and - so no range check can fail.
- **overflow**: The bracket-matching depth counter and the step counter are bounded by the program length and a documented step limit, guarded before each increment.
- **termination**: The interpreter loop lives in a procedure, which gets no termination check, and a documented step limit stops non-terminating Brainf*** programs with a visible message.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, case statements, for loops, while loops, procedures, Put without a newline and standard input.

## External effects

- **console output** (allowed): The '.' command writes the cell's character to standard output.
- **standard input** (allowed): The ',' command reads one character from standard input, with a specified value stored on end of input.

Assessed on 2026-10-15 against page revision 414943 of the [task](https://rosettacode.org/wiki/Execute_Brain%2A%2A%2A%2A) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
