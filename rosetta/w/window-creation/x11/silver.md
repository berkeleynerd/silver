# Window creation/X11

**Excluded from Silver: GUI, graphics.** The task needs an on-screen X11 window with a box and text, which is a gui and graphics effect Silver lacks, not a conflict. A Silver-friendly version would reach the X server through an admitted X11 binding (or a direct protocol client over an admitted socket operation), with a bounded event loop that redraws on expose, so no fixed Oracle rule is broken.

## External effects

- **GUI** (not allowed): The task requires opening a real X11 window on the display server and receiving its expose and close events.
- **graphics** (not allowed): The task requires drawing a box and the text "Hello World" inside that window.

Assessed on 2026-10-15 against page revision 415558 of the [task](https://rosettacode.org/wiki/Window_creation/X11) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
