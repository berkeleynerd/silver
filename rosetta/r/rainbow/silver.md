# Rainbow

**Excluded from Silver: terminal control.** The task is to print RAINBOW with each letter in a different color. That needs only text output plus terminal color control, so it is an effect Silver lacks today rather than a rule conflict. A bounded loop or array of color codes over the letters would work.

## Language surface recorded by this assessment

Characters, string operations, loops and arrays.

## External effects

- **console output** (allowed): Prints the word RAINBOW, one letter at a time, each in a different color.
- **terminal control** (not allowed): Coloring each character requires terminal color control, which an admitted library operation would have to provide (for example by emitting ANSI color escape sequences).

Assessed on 2026-10-15 against page revision 415355 of the [task](https://rosettacode.org/wiki/Rainbow) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
