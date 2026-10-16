# Draw a clock

**Excluded from Silver: clock, delay.** The task can be met by a text-art clock (a second hand drawn on a character grid) redrawn each second from the system clock with a delay, which needs only console output, clock and delay effects. Nothing in the requirements conflicts with the Oracle rules; the SDL window in the existing solution is not required.

## Language surface recorded by this assessment

Integers, arrays, loops, subprograms, characters and string operations.

## External effects

- **console output** (allowed): Text-art clock face (e.g. a rotating second hand drawn with characters) printed to the console; text-based drawing is explicitly allowed.
- **clock** (not allowed): Must read the system clock so the displayed seconds agree with it.
- **delay** (not allowed): Must update once per second using a timer or delay rather than busy polling.

Assessed on 2026-10-15 against page revision 415031 of the [task](https://rosettacode.org/wiki/Draw_a_clock) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
