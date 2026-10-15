# Draw pixel 2

**Excluded from Silver: GUI, graphics, delay.** The task explicitly asks for a window, so the GUI and graphics effects are real requirements, not conflicts. A Silver-friendly solution uses a deterministic generator over an integer range 0..639 by 0..479 to pick the pixel, a loop that waits for a quit event, and a short delay between polls. Nothing in the task requires assertions, exceptions, unsafe constructs or run-time errors, so no fixed Oracle rule is broken. The existing Ada solution's use of the SDL binding is only evidence of the effect and does not add a conflict.

## Language surface beyond today's Silver

Integers and loops.

## External effects

- **GUI** (not allowed): The task explicitly requires creating a 640 x 480 window that shows the pixel.
- **graphics** (not allowed): A yellow (255,255,0) pixel must be drawn at a random position on a black 640 x 480 surface in that window.
- **delay** (not allowed): The window must stay open until the user closes it, so the program idles between event polls (for example a 100 ms sleep in a loop).

Assessed on 2026-10-15 against page revision 408685 of the [task](https://rosettacode.org/wiki/Draw_pixel_2) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
