# Window management

**Excluded from Silver: GUI, delay.** The task needs a window-manager interface: storing and comparing window handles, then hiding, showing, closing, minimizing, maximizing, moving and resizing windows. Silver would need an admitted library that specifies those operations, which makes this a missing gui effect and not a conflict with any fixed Oracle rule. The task asks for the window operations themselves, so text output alone would not meet it.

## External effects

- **GUI** (not allowed): The task requires hiding, showing, closing, minimizing, maximizing, moving and resizing windows, and holding window identities that can be compared. That means a windowing system, possibly one the program did not create.
- **console output** (allowed): The program should print each step it performs and the window identity comparisons.
- **delay** (not allowed): The program pauses between steps so each change to the window can be seen.

Assessed on 2026-10-15 against page revision 409055 of the [task](https://rosettacode.org/wiki/Window_management) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
