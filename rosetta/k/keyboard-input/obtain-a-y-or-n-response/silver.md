# Keyboard input/Obtain a Y or N response

**Excluded from Silver: terminal control.** A loop reads single keystrokes through an admitted terminal/keyboard operation (immediate, flushed, no Enter) until Y/y or N/n is seen, then returns the answer. That is ordinary SPARK with no rule conflicts. Silver would need a specified raw-keyboard library operation, including an outcome for end of input.

## Language surface beyond today's Silver

Characters, loops and subprograms.

## External effects

- **terminal control** (not allowed): The task needs unbuffered, immediate keystroke reads with no Enter key, and flushing of pending key-presses, which is raw-terminal behavior.
- **standard input** (allowed): The Y or N response comes from the keyboard as input characters, read repeatedly until a valid one arrives.
- **console output** (allowed): A prompt asking for Y or N is shown.

Assessed on 2026-10-15 against page revision 414914 of the [task](https://rosettacode.org/wiki/Keyboard_input/Obtain_a_Y_or_N_response) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
