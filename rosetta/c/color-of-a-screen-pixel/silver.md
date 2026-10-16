# Color of a screen pixel

**Excluded from Silver: graphics.** The task is to read the color of an arbitrary screen pixel, which needs a display read through an OS API (graphics effect), with coordinates passed as arguments and the color printed as text. The optional mouse-cursor position is left out because the task says "such as" and does not require it. The FreeBASIC example only reads a pixel from its own graphics buffer, so it is weak evidence, but no Oracle rule is broken by reading a screen pixel, so there are no conflicts.

## Language surface recorded by this assessment

Integers.

## External effects

- **graphics** (not allowed): The task needs to read the color of an arbitrary pixel on the actual screen, which requires access to the display's framebuffer through an OS API. This is an effect Silver lacks, not a conflict.
- **console output** (allowed): The program reports the color value (for example as an RGB or palette triple) as text on the console.
- **arguments** (allowed): The pixel coordinates can be taken from command-line arguments so the program works for any screen position.

Assessed on 2026-10-15 against page revision 415035 of the [task](https://rosettacode.org/wiki/Color_of_a_screen_pixel) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
