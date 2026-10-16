# GUI enabling/disabling of controls

**Excluded from Silver: GUI.** The task is an interactive GUI form, so it needs a window with a text field and two buttons whose enabled state is recomputed from the value. Nothing in the wording breaks an Oracle rule: manual entry outside 0..10 is allowed, so the value must be a bounded integer with a specified outcome for unparsable or out-of-range text (for example rejecting it), and the event loop can be a plain iteration over GUI events. The existing Ada solution's exception-based parsing is not required and is left out.

## Language surface recorded by this assessment

Integers, string operations, loops and subprograms.

## External effects

- **GUI** (not allowed): The task requires a form with a numeric input field and increment/decrement buttons whose enabled state changes with the value; these are GUI widgets, which Silver lacks, so this is an effect rather than a conflict.

Assessed on 2026-10-15 against page revision 378433 of the [task](https://rosettacode.org/wiki/GUI_enabling/disabling_of_controls) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
