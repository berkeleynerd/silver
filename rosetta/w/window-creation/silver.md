# Window creation

**Excluded from Silver: GUI.** The task asks for a GUI window that can be closed, so the only effect needed is gui. No Oracle rule is broken: an admitted program could create a window through a future admitted library operation with specified failure outcomes, and the close request can be handled by ordinary control flow without exceptions, annotations or unsafe constructs. The existing GtkAda solution uses callbacks and a main loop, but those are only evidence of how the existing solution is written, so they are not reported as features.

## External effects

- **GUI** (not allowed): The task explicitly asks to display a GUI window that responds to close requests, which needs a windowing toolkit Silver does not have. The task does not allow a text or file substitute.

Assessed on 2026-10-15 against page revision 404836 of the [task](https://rosettacode.org/wiki/Window_creation) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
