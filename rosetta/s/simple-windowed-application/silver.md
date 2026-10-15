# Simple windowed application

**Excluded from Silver: GUI, hardware.** The task requires a window with a label and a mouse-clickable button, which is a GUI effect that a future admitted windowing library could provide, so it is not a fixed-rule conflict. The click count can be a bounded integer with an explicit guard, and the event loop can be a single admitted library call, so no features beyond the library operations are needed. Confidence is medium because the event-callback mechanism may need a Silver-specific design.

## External effects

- **GUI** (not allowed): The task explicitly requires a window containing a label and a clickable button, so a GUI toolkit or an admitted windowing library operation is needed. Text output cannot satisfy the requirement to create a window.
- **hardware** (not allowed): Mouse input from the user is needed to detect button clicks. This is an input event delivered by the windowing system.

Assessed on 2026-10-15 against page revision 409446 of the [task](https://rosettacode.org/wiki/Simple_windowed_application) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
