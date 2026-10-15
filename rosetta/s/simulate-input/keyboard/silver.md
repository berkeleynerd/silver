# Simulate input/Keyboard

**Excluded from Silver: GUI, delay.** The task asks for simulated keystrokes sent to a GUI window or terminal, and says whether the target may be another application. That needs an OS-level input-injection operation, which Silver lacks today. A future admitted library operation could specify it, so this is an effect and not a conflict with an Oracle rule.

## External effects

- **GUI** (not allowed): The task sends simulated keystrokes to a GUI window or terminal, so the program needs an OS service that injects keyboard events into another application. Silver has no such operation.
- **console output** (allowed): A solution prints a prompt or countdown telling the user to make the target window active before the keys are sent.
- **delay** (not allowed): A solution waits a few seconds so the user can focus the target window before the keystrokes are sent.

Assessed on 2026-10-15 against page revision 385214 of the [task](https://rosettacode.org/wiki/Simulate_input/Keyboard) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
