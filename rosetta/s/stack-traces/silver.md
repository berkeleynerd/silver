# Stack traces

**Excluded from Silver: outside SPARK.** Excluded. The task requires inspecting the real run-time call stack, including the function name in each frame. That is reflection on program structure, which SPARK cannot express (GNAT.Traceback relies on addresses and debug symbols outside SPARK).

## Language surface beyond today's Silver

Subprograms and string operations.

## Oracle conflicts

- **outside SPARK**: The task requires printing the program's actual current call stack, which is run-time introspection of program structure. SPARK cannot express it: the only Ada route is GNAT.Traceback, which works on raw code addresses and symbolic debug information and is outside SPARK. A shadow stack of names that the program keeps by hand would be a simulation, not the real call stack.

## External effects

- **console output** (allowed): The stack trace is printed to the console, and then the program carries on.

Assessed on 2026-10-15 against page revision 413231 of the [task](https://rosettacode.org/wiki/Stack_traces) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
