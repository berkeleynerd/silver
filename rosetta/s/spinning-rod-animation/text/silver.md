# Spinning rod animation/Text

**Excluded from Silver: terminal control, delay.** The task is a looping or finite text spinner that cycles four ASCII frames with a 0.25 s delay and clears the previous frame, so it needs console output, terminal control and delay. Nothing in it breaks an Oracle rule, so it is a candidate once Silver gains those effects; a finite number of frames avoids any need for an endless loop or key-press polling.

## Language surface recorded by this assessment

Arrays, loops and enumerations.

## External effects

- **console output** (allowed): Prints each spinner frame (| / - \) as text.
- **terminal control** (not allowed): Each frame must clear the previous one, which needs cursor control or a carriage return or backspace overwrite on the terminal.
- **delay** (not allowed): A 0.25 second pause is required between frames.

Assessed on 2026-10-15 against page revision 413526 of the [task](https://rosettacode.org/wiki/Spinning_rod_animation/Text) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
