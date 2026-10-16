# Terminal control/Dimensions

**Excluded from Silver: terminal control.** The task only asks to read the terminal height and width into variables. That needs a terminal-size operation that Silver does not have yet, which makes it an effect rather than a conflict with any Oracle rule. A bounded Integer or natural-range pair is enough to hold the values, and the operation must specify what happens when no terminal is attached.

## Language surface recorded by this assessment

Integers.

## External effects

- **terminal control** (not allowed): The task requires querying the terminal's height and width, which is terminal screen-size information.
- **console output** (allowed): The values are stored in variables and can be printed to show them. This is optional and not required by the task.

Assessed on 2026-10-15 against page revision 413242 of the [task](https://rosettacode.org/wiki/Terminal_control/Dimensions) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
