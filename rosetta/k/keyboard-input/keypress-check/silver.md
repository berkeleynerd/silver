# Keyboard input/Keypress check

**Excluded from Silver: terminal control.** The task asks for a non-blocking check for a key press, stored in a variable. A Silver program can express this with a bounded Character and a Boolean once an admitted library operation provides non-blocking keystroke input with specified outcomes. It breaks no fixed Oracle rule. It only needs a stdin or terminal effect that Silver lacks today.

## External effects

- **standard input** (allowed): The task needs a non-blocking check of whether a key has been pressed on the keyboard and a read of that key. This is an interactive input device, so it is a stdin or terminal effect.
- **terminal control** (not allowed): A key press must be detected without waiting and without line buffering. That needs raw or immediate keystroke access.

Assessed on 2026-10-15 against page revision 409183 of the [task](https://rosettacode.org/wiki/Keyboard_input/Keypress_check) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
