# Dynamic variable names

**Excluded from Silver: outside SPARK.** The task asks for a real variable whose name is chosen at run time. Ada/SPARK cannot bind names at run time, so this falls outside SPARK. A bounded array of name/value records, searched linearly, would only simulate the effect, as the FreeBASIC solution itself says.

## Language surface recorded by this assessment

String operations, arrays, records and loops.

## Oracle conflicts

- **outside SPARK**: The task requires creating a program variable whose name comes from the user at run time. Ada/SPARK binds every variable name statically at compile time and has no run-time evaluation or reflective symbol creation. A bounded name-to-value table only simulates the effect, as the FreeBASIC entry admits; it does not create a variable, so it does not meet the requirement as written.

## External effects

- **standard input** (allowed): The variable name (and its value) must be taken from the user dynamically, so the program reads input.
- **console output** (allowed): The program prompts the user and prints the variable's value back.

Assessed on 2026-10-15 against page revision 412757 of the [task](https://rosettacode.org/wiki/Dynamic_variable_names) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
