# Matrix digital rain

**Excluded from Silver: delay, terminal control.** The task asks for an animated terminal rain effect. A single-task solution can use a deterministic pseudo-random generator, a fixed-size array of column states, and frame-by-frame redraw with ANSI escapes, so it needs only console output, terminal control, delays and optional input. No Oracle rule is broken.

## Language surface beyond today's Silver

Integers, characters, arrays, loops, subprograms, packages and enumerations.

## External effects

- **console output** (allowed): Rain characters are printed as text to a terminal, using ANSI escape sequences for cursor placement and green color.
- **delay** (not allowed): Animation needs timed pauses between frames to look like falling rain.
- **terminal control** (not allowed): The task is a terminal effect needing cursor positioning, colors, clearing the screen and hiding the cursor, which the Common Lisp reference does with ANSI/curses.
- **standard input** (allowed): A key press is the natural way to stop the animation, or the run can be bounded to a fixed number of frames.

Assessed on 2026-10-15 against page revision 414908 of the [task](https://rosettacode.org/wiki/Matrix_digital_rain) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
