# Hostname

**Excluded from Silver: environment.** The task asks only to find the name of the host the program is running on. A Silver program can do this by calling an admitted library operation that returns the host name as a bounded string and then printing it, so no Oracle rule is broken. What Silver lacks today is a system-information effect, not anything a fixed rule forbids.

## Language surface recorded by this assessment

String operations.

## External effects

- **environment** (not allowed): The program has to ask the operating system for the host name, so it needs an admitted library operation that queries system information, with a specified outcome when the lookup fails.
- **console output** (allowed): The program prints the host name it finds.

Assessed on 2026-10-15 against page revision 409659 of the [task](https://rosettacode.org/wiki/Hostname) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
