# Metronome

**Excluded from Silver: delay, clock, sound.** A metronome needs a configurable tempo and beat pattern, a timed loop with delays, a text visual indicator and optionally sound; none of this breaks an Oracle rule. It needs the delay, clock, sound, arguments and console-output effects, with validated bounded tempo and pattern input.

## Language surface beyond today's Silver

Loops, integers, enumerations, string operations and arrays.

## External effects

- **console output** (allowed): The visual beat indicator and high/low beat display can be printed as text lines in the terminal.
- **delay** (not allowed): The metronome must wait between beats to keep tempo.
- **clock** (not allowed): Beat timing needs elapsed time so the tempo stays steady and is not affected by the time spent producing output.
- **arguments** (allowed): Tempo and beat pattern must be configurable, taken from command-line arguments.
- **sound** (not allowed): The task calls for audible high and low beats, for example by terminal bell or an external player; a visual-only version is allowed but sound is the primary requirement.

Assessed on 2026-10-15 against page revision 414906 of the [task](https://rosettacode.org/wiki/Metronome) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
