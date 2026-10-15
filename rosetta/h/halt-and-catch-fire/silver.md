# Halt and catch fire

**Excluded from Silver: run-time error.** The task asks for a program that deliberately crashes, for example by raising Program_Error. Silver requires proof that no run-time error or exception can happen, so the task conflicts with that fixed Oracle rule and cannot be included.

## Oracle conflicts

- **run-time error**: The task's only requirement is a program that crashes as soon as possible, meaning deliberate abnormal termination through a run-time error or a raised exception. Oracle rule 2 requires every admitted program to be proved free of run-time errors and raised exceptions, so no Silver program can crash on purpose. A clean exit with a failure status would be a controlled termination, which is a different task (Program termination).

Assessed on 2026-10-15 against page revision 413233 of the [task](https://rosettacode.org/wiki/Halt_and_catch_fire) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
