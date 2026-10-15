# GUI component interaction

**Excluded from Silver: GUI, OS services.** The task needs a GUI window with a numeric field, two buttons and a Yes/No confirmation dialog, which Silver lacks, so it is an effect, not a conflict. Non-numeric input can be rejected with a visible error or refused, and the random value can come from a deterministic generator seeded in the program, so no entropy or other conflicting construct is needed. Increment overflow of the Natural range is not required by the task, so no runtime-error conflict is reported. The GUI binding's callbacks are an implementation detail of the effect, so no features are listed beyond the effect itself.

## External effects

- **GUI** (not allowed): The task requires a window presenting a form with a numeric input field, an "increment" button and a "random" button, plus a confirmation dialog shown when "random" is pressed.
- **OS services** (not allowed): Not required by the task; left out.

Assessed on 2026-10-15 against page revision 402837 of the [task](https://rosettacode.org/wiki/GUI_component_interaction) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
