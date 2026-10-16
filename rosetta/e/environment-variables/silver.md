# Environment variables

**Excluded from Silver: environment.** The task is to read one environment variable and print it. A Silver program can do this with a guarded library lookup (check that the variable exists, then read its value, with a visible message when it is absent) followed by text output. Nothing in the task breaks an Oracle rule, so it can be included once Silver admits an environment-variable library operation.

## Language surface recorded by this assessment

String operations.

## External effects

- **environment** (not allowed): Must read one of the process's environment variables (e.g. PATH, HOME or USER) through an admitted library operation that checks the variable exists and specifies what happens when it is missing.
- **console output** (allowed): Prints the variable's value, or a specified message if the variable is not set.

Assessed on 2026-10-15 against page revision 412766 of the [task](https://rosettacode.org/wiki/Environment_variables) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
