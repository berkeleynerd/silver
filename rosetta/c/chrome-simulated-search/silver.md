# Chrome simulated search

**Excluded from Silver: GUI, processes, OS services.** The task asks a program to open a browser and run a search using a keyboard shortcut, without the mouse or typed search text. No fixed Oracle rule is broken. It depends on external effects Silver lacks (launching a process, GUI/keystroke injection), so it is not coverable today, but it is not excluded by the Oracle rules either.

## External effects

- **GUI** (not allowed): The task requires launching or driving a web browser and sending keyboard shortcuts to it (new tab, then submit a search), which is interaction with another program's windows.
- **processes** (not allowed): A browser has to be launched programmatically, which means starting an external program.
- **OS services** (not allowed): Simulating keystrokes into another application needs operating-system input injection.

Assessed on 2026-10-15 against page revision 414821 of the [task](https://rosettacode.org/wiki/Chrome_simulated_search) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
