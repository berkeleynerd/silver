# Draw a pixel

**Excluded from Silver: GUI, graphics.** The task explicitly requires a window, so a text or file substitute would not meet it; the only needs are GUI window creation and display drawing, which Silver lacks but which are effects, not Oracle conflicts. The solution needs only integer constants and a single fixed-size window, so no additional SPARK features are required. The existing SDLAda solution's loop, delay and event polling are not needed for a Silver-friendly version and are not reported.

## External effects

- **GUI** (not allowed): The task requires creating a 320 x 240 window, which is a GUI window and is not optional.
- **graphics** (not allowed): The task requires drawing a red (255,0,0) pixel at x=100, y=100 inside that window, which is drawing on a display.

Assessed on 2026-10-15 against page revision 413326 of the [task](https://rosettacode.org/wiki/Draw_a_pixel) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
