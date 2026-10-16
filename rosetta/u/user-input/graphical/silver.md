# User input/Graphical

**Excluded from Silver: GUI.** The task asks for a string and the integer 75000 to be entered through a graphical user interface, so the GUI is an effect Silver lacks, not a conflict. Nothing in the wording requires exceptions, assertions, or other fixed-rule violations; the GtkAda solution's exception handler and callbacks are incidental to how it was written. A Silver-friendly version would validate integer text with explicit character loops and a specified rejection outcome for invalid input, so the features are integers, characters, string operations and loops.

## Language surface recorded by this assessment

Integers, characters, string operations and loops.

## External effects

- **GUI** (not allowed): The task requires taking a string and an integer from a graphical user interface, so a window with text entry widgets and an event loop is needed.

Assessed on 2026-10-15 against page revision 408670 of the [task](https://rosettacode.org/wiki/User_input/Graphical) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
