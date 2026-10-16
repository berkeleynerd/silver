# Program name

**Candidate: proofs likely to discharge automatically.** The program is just one library call whose result goes straight to output, so it has no run-time checks beyond the admitted operations' own contracts. The only new thing Silver needs is a command-name operation in its arguments library.

Position 1439 in the [progression](../../progression.md#stage-27), in stage 27, which adds further arguments.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

A parameterless Main procedure passes the result of an admitted Silver_Arguments command-name operation (the counterpart of Ada.Command_Line.Command_Name, which returns an unconstrained String) straight to Silver_IO.Put_Line. There are no loops, no arithmetic and no guards beyond whatever the admitted operation's contract specifies for an unavailable name. About 8 lines.

## Language surface recorded by this assessment

Further arguments.

## External effects

- **arguments** (allowed): The program must read the name it was invoked with, which needs an admitted Command_Name-style operation alongside Silver_Arguments' argument access.
- **console output** (allowed): The obtained program name is printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413208 of the [task](https://rosettacode.org/wiki/Program_name) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
