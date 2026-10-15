# Mouse position

**Excluded from Silver: GUI, hardware.** The task asks for the mouse cursor position relative to the active window, which needs a GUI window and pointing-device input. Both are external effects Silver lacks, not Oracle-rule conflicts, so no conflicts are reported. No features beyond today's Silver are needed because the effects are the only blocker.

## External effects

- **GUI** (not allowed): The task needs the active window and the pointer position relative to it, which requires a windowing system. The existing solution uses GTK windows.
- **hardware** (not allowed): The task reads the current position of the mouse, a pointing device, so it needs device input that Silver does not have.

Assessed on 2026-10-15 against page revision 409753 of the [task](https://rosettacode.org/wiki/Mouse_position) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
