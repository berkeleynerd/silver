# On-screen keyboard

**Excluded from Silver: GUI, terminal control.** The task file holds only the title, so the requirement is inferred from the name and the FreeBASIC solution. It is a virtual keyboard shown in a window and responding to input, which needs GUI and raw key input effects. Nothing in it breaks an Oracle rule, so it could be covered once Silver has such admitted library operations.

## Language surface recorded by this assessment

Arrays, records, loops, subprograms, string operations, integers and enumerations.

## External effects

- **GUI** (not allowed): The task is an on-screen (virtual) keyboard that is shown in a window and reacts to key presses or clicks. The task file has only a title, so this comes from the task name and the existing solution. A console text-art keyboard would not be a real on-screen keyboard.
- **terminal control** (not allowed): The solution detects raw key presses and shows which key is down, which needs raw keystroke input.

Assessed on 2026-10-15 against page revision 411079 of the [task](https://rosettacode.org/wiki/On-screen_keyboard) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
