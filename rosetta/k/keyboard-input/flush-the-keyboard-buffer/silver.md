# Keyboard input/Flush the keyboard buffer

**Excluded from Silver: terminal control.** The task is to drain already-buffered keyboard input without waiting, a loop around a non-blocking immediate-read operation; this needs a stdin/terminal library operation with specified non-blocking behavior but breaks no fixed Oracle rule.

## Language surface recorded by this assessment

Loops.

## External effects

- **standard input** (allowed): Must read and discard whatever input is already buffered on standard input/keyboard, without blocking when none is available (non-blocking read of pending input).
- **terminal control** (not allowed): The task is about the keyboard device buffer and requires a non-waiting, immediate read of pending keystrokes, which is terminal input control beyond ordinary line reads.

Assessed on 2026-10-15 against page revision 415048 of the [task](https://rosettacode.org/wiki/Keyboard_input/Flush_the_keyboard_buffer) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
