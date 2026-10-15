# Animation

**Excluded from Silver: GUI, delay.** The Silver-friendly solution is a single event loop with no recursion or tasking. It holds a bounded string of 13 characters and a Boolean direction flag, rotates the string one character per tick, and polls the window for clicks and close requests between ticks. The task needs a window and clickable text, so the GUI effect is required. Nothing in the task requires an exception, assertion, pointer or run-time error, so no conflict arises.

## External effects

- **GUI** (not allowed): The task requires a window containing a text label that the user can click to reverse the rotation direction. Both the window and the click events are GUI effects.
- **delay** (not allowed): The text must rotate periodically, so the program needs to pause between steps (the existing solution uses a 125 ms timeout). A fixed sleep or a polled timer between redraws satisfies this.

Assessed on 2026-10-15 against page revision 409374 of the [task](https://rosettacode.org/wiki/Animation) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
