# Sleep

**Excluded from Silver: delay.** The task reads a sleep duration, prints \"Sleeping...\", delays, then prints \"Awake!\". It needs only integer parsing with input validation plus stdin, console-output and delay effects, so it breaks no fixed Oracle rule.

## Language surface recorded by this assessment

Integers.

## External effects

- **standard input** (allowed): Reads the amount of time to sleep (e.g. in milliseconds) from standard input or an argument.
- **console output** (allowed): Prints "Sleeping..." before the delay and "Awake!" after it.
- **delay** (not allowed): Sleeps the main thread for the given amount of time.

Assessed on 2026-10-15 against page revision 413521 of the [task](https://rosettacode.org/wiki/Sleep) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
