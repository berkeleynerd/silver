# Animated Spinners

**Excluded from Silver: graphics.** The task is an animated on-screen display of five spinners, so the Silver-friendly solution needs a graphics effect and no rule is broken. A solution can use a fixed-step integer angle per frame with an integer or table-based line geometry, a bounded frame loop, and a fixed array of five spinner records, avoiding floating-point trig, delay and the window-closing check. Text art would not clearly satisfy the "display" wording, so graphics is reported.

## Language surface recorded by this assessment

Integers, arrays, records and loops.

## External effects

- **graphics** (not allowed): The task asks to create and display five animated spinners on screen, which needs drawing to a display (the example opens a Raylib window). Silver has no graphics effect yet, but this is an effect, not a conflict.

Assessed on 2026-10-15 against page revision 408742 of the [task](https://rosettacode.org/wiki/Animated_Spinners) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
