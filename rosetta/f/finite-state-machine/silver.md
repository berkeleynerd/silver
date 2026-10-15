# Finite state machine

**Candidate: proofs likely to discharge automatically.** All checks are index checks over the String's own range and enumeration-valued assignments, so no loop-carried value needs an invariant and the for loop terminates by itself. Embedding the input script avoids stdin and keeps the program deterministic, with invalid signals handled explicitly.

Position 1163 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

An enumeration State (Ready, Waiting, Dispensing, Refunding, Done) holds the current state, and the demo input signals are an embedded constant String such as "dsrdrq" walked by a for loop over Script'Range. Each iteration first runs the implicit transition (Refunding to Ready) if applicable, then a case on the state with a nested case on the Character signal either advances the state or prints an invalid-input message and stays put, exiting the loop at Done. Signals left over after Done or an exhausted script have a specified outcome (stop, with a final state line). About 50 lines.

## Language surface beyond today's Silver

Enumerations, characters, string indexing, case statements, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each state and the handling of each scripted input signal with Put_Line.

Assessed on 2026-10-15 against page revision 412552 of the [task](https://rosettacode.org/wiki/Finite_state_machine) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
