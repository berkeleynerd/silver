# Universal Lambda Machine

**Candidate: proofs plausibly discharge automatically.** The interpreter needs only bounded arrays, records and procedure loops with explicit capacity guards, so no annotation is needed, but the many loop-carried pool indices and the pointer-to-index redesign make careful program shape necessary. Non-halting or oversized programs end through a specified resource-limit outcome rather than a hidden failure.

Position 1452 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Read the input into a bounded buffer, parse the BLC term into a fixed-capacity array of tagged term cells (lambda, application, variable index) via an explicit stack in a while loop inside a procedure, and evaluate it with a call-by-need environment machine whose closures and environments are index-based records in fixed pools. The evaluator loop runs in a procedure with a step budget and capacity guards before every pool or stack access, and the output list of bits or bytes is decoded and written as it is produced, rejecting visibly on exhaustion or malformed input. About 260 lines.

## Proof obligations to watch

- **index**: Term-array, environment-node pool and stack indices are loop-carried and must each be guarded against the fixed capacity, with exhaustion producing a visible out-of-resources outcome.
- **termination**: The reduction loop and the parser loop run in procedures, which get no termination check, and a step budget makes non-halting BLC programs end visibly.
- **initialization**: Fixed pools of nodes, term cells and stack must be fully initialized before use, which is routine with aggregate initialization but sizeable.
- **overflow**: Reference counts and bit accumulators are bounded by pool capacity or masked into small ranged types so guards suffice.
- **other**: The existing design uses heap cells and a reference-count free list, so the program must replace them with index-based array pools and an explicit capacity limit, and stack or heap exhaustion becomes a specified rejection.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, unconstrained arrays, case statements, for loops, while loops, procedures, functions, standard input, Put without a newline, further arguments and text parsing.

## External effects

- **standard input** (allowed): The BLC program bits or bytes and its input are read from standard input.
- **console output** (allowed): The machine's output bits or bytes are written to standard output.
- **arguments** (allowed): The -b flag selects bit mode over the default byte mode.

Assessed on 2026-10-15 against page revision 415111 of the [task](https://rosettacode.org/wiki/Universal_Lambda_Machine) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
