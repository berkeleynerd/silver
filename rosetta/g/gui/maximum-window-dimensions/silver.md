# GUI/Maximum window dimensions

**Excluded from Silver: GUI.** The task needs the usable display area for a maximized window, which only a windowing system can report, so it needs a gui effect. Silver has no such effect yet, but this is an effect gap and not an Oracle conflict. The program itself needs no recursion, pointers, assertions or exceptions, and it only prints the two integers, so the only missing piece is the gui effect.

## External effects

- **GUI** (not allowed): The task asks for the usable area of the screen as it would be for a maximized window, which needs a windowing toolkit to create and maximize a window and read its size. The existing Ada solution uses GTK for this. No text-only alternative measures the usable window area.

Assessed on 2026-10-15 against page revision 377265 of the [task](https://rosettacode.org/wiki/GUI/Maximum_window_dimensions) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
