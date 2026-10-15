# Terminal control/Inverse video

**Excluded from Silver: terminal control.** The task prints one word in inverse video and then one in normal video, which a program can do by writing ANSI escape sequences as constant text. It needs only console output and terminal attribute control. It breaks no Oracle rule.

## Language surface beyond today's Silver

String operations and characters.

## External effects

- **console output** (allowed): Prints the words as text, including the ANSI escape sequences that switch inverse video on and off.
- **terminal control** (not allowed): Inverse (reverse) video is a terminal display attribute, controlled through terminal escape codes.

Assessed on 2026-10-15 against page revision 415093 of the [task](https://rosettacode.org/wiki/Terminal_control/Inverse_video) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
