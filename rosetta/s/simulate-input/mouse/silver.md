# Simulate input/Mouse

**Excluded from Silver: GUI, OS services.** The only requirement is to inject a mouse-button click into a GUI target, which needs windowing and OS input-injection services that Silver does not provide yet. No Oracle rule is broken: an admitted library operation could give the click, with its failure outcomes specified, so the task is a candidate for future Silver coverage.

## Language surface recorded by this assessment

Integers.

## External effects

- **GUI** (not allowed): The task is to click a mouse button on a GUI target, which may be a window the program creates itself or one created externally, so the program has to reach a windowing system.
- **OS services** (not allowed): Simulating a user's mouse click means injecting a synthetic input event through an operating-system or window-system input service, such as SendInput or XTest.

Assessed on 2026-10-15 against page revision 409924 of the [task](https://rosettacode.org/wiki/Simulate_input/Mouse) by claude-opus-5-5 at high effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
