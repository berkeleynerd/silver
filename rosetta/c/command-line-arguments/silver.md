# Command-line arguments

**Candidate: proofs likely to discharge automatically.** The only check that is not trivial is the index precondition on the library's argument accessor, and a for loop over 1 .. Argument_Count meets it directly. The program needs only a library extension (argument count and indexed access) plus for loops, with no arithmetic or loop-carried state.

Position 1440 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Main is a procedure that runs a for loop from 1 to the admitted library's argument count and passes each argument to Silver_IO.Put_Line. It stores no data, so it needs no buffers, and the loop bounds act as the only guard. With zero arguments the loop does nothing and the output is empty. About 12 lines.

## Proof obligations to watch

- **index**: The admitted Argument operation's precondition (index between 1 and the argument count) discharges because the for-loop index ranges exactly over 1 .. Argument_Count.

## Language surface beyond today's Silver

For loops and further arguments.

## External effects

- **arguments** (allowed): The program retrieves every command-line argument and the argument count.
- **console output** (allowed): Each retrieved argument is printed on its own line to show the list was obtained.

Assessed on 2026-10-15 against page revision 413624 of the [task](https://rosettacode.org/wiki/Command-line_arguments) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
