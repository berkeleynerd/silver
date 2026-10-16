# Terminal control/Unicode output

**Excluded from Silver: environment.** The program checks the locale environment for a UTF-8 setting, then prints the three-byte UTF-8 form of U+25B3, or else prints an error message and exits nonzero. This needs only environment access, console output and exit status. The task's 'error should be raised' can be met by a reported error outcome, so no exception is required.

## Language surface recorded by this assessment

Characters and string operations.

## External effects

- **environment** (not allowed): Decide whether the terminal supports Unicode by reading locale variables (LANG, LC_ALL, LC_CTYPE), which the task explicitly allows as system configuration data.
- **console output** (allowed): Print the UTF-8 encoded delta (U+25B3) when Unicode is supported, or a diagnostic message when it is not.
- **exit status** (allowed): Return a nonzero exit status to report the unsupported-terminal error as a visible, specified outcome.

Assessed on 2026-10-15 against page revision 413248 of the [task](https://rosettacode.org/wiki/Terminal_control/Unicode_output) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
