# Closures/Value capture

**Excluded from Silver: outside SPARK.** The task's stated goal is to create independent closures, each capturing the value of a loop variable, which SPARK cannot express: it has no closures or anonymous functions, and access-to-subprogram values are restricted. The existing Ada answer works around this with an array of protected objects, which simulates closures rather than providing them, so the task is excluded as outside-spark.

## Language surface recorded by this assessment

Integers, arrays, loops and subprograms.

## Oracle conflicts

- **outside SPARK**: The task requires a list of ten functions (anonymous functions encouraged), each closing over a separate copy of a loop counter's value. That means first-class function values that capture state at run time. SPARK has no closures or anonymous functions, and it restricts access-to-subprogram values so a nested subprogram that captures local state cannot be stored in a list. An array of records holding the index, read by one shared squaring function, only imitates the goal. The task explicitly asks to demonstrate closures.

## External effects

- **console output** (allowed): Prints the result of calling one or more of the captured functions (for example 1 4 9 ... 81).

Assessed on 2026-10-15 against page revision 414114 of the [task](https://rosettacode.org/wiki/Closures/Value_capture) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
