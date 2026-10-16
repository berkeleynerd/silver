# Joystick position

**Excluded from Silver: hardware.** The task permits a plus-symbol crosshair on a terminal and text for button status, so a solution needs only console output plus a joystick device read, which is an effect Silver lacks rather than a conflict. The continuous redraw loop is a plain unbounded loop with no conflict under the Oracle rules, and the axes map to bounded integer ranges with a defined full-extent fallback for digital joysticks. No recursion, pointers, or exceptions are required.

## Language surface recorded by this assessment

Integers, loops, arrays, characters and string operations.

## External effects

- **hardware** (not allowed): Reading the first joystick's axis positions and pushbutton states requires a device that Silver has no admitted library operation for.
- **console output** (allowed): The crosshair is drawn as text (a plus symbol on a character grid) and the button status is printed as an alphanumeric sequence, which the task explicitly allows in place of a graphical display.

Assessed on 2026-10-15 against page revision 415018 of the [task](https://rosettacode.org/wiki/Joystick_position) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
