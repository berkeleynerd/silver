# Call a foreign-language function

**Excluded from Silver: unsafe operations.** Not a candidate. The task exists to demonstrate calling a foreign-language (C) function, and foreign-language calls are permanently outside Silver under the Oracle's fixed rules. Printing the result is the only other part, and that is just console output.

## Language surface recorded by this assessment

String operations and subprograms.

## Oracle conflicts

- **unsafe operations**: The whole point of the task is to call a function written in another language (for example C's strdup) through a foreign function interface. Rule 8 lists foreign-language calls among the constructs that are never available, and the C side cannot be proved free of run-time errors (Rule 2). So no Silver program can do what the task requires.

## External effects

- **console output** (allowed): The program must print the string that the foreign function returns.

Assessed on 2026-10-15 against page revision 414768 of the [task](https://rosettacode.org/wiki/Call_a_foreign-language_function) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
