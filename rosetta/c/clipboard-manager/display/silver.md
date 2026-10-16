# Clipboard manager/display

**Excluded from Silver: GUI, OS services, terminal control.** The task needs a GUI window, system clipboard monitoring and a key combination hook, which are external effects Silver lacks today, together with a bounded 10-entry queue of strings, which fits Silver's bounded arrays and strings. Nothing in it breaks a fixed Oracle rule, so it could be covered by a future Silver once those admitted library operations exist.

## Language surface recorded by this assessment

Arrays, loops, subprograms, records and string operations.

## External effects

- **GUI** (not allowed): The task requires a window showing the 10 most recent copies, a clear button, and an optional always-on-top pin.
- **OS services** (not allowed): Observing the system clipboard (Ctrl+C copies made in other applications) and reading the highlighted text is an operating-system service.
- **terminal control** (not allowed): Capturing the Ctrl+C key combination as a hotkey and keystroke.

Assessed on 2026-10-15 against page revision 413278 of the [task](https://rosettacode.org/wiki/Clipboard_manager/display) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
