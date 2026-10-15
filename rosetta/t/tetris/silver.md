# Tetris

**Excluded from Silver: terminal control, clock, delay.** Tetris can be written in plain bounded SPARK: a fixed 7x4x4x4 shape table, a bounded board array, and a deterministic pseudo-random piece generator, with text-art rendering. It needs interactive terminal key input, timing and delay effects that Silver lacks today, but no fixed Oracle rule is broken.

## Language surface beyond today's Silver

Arrays, records, enumerations, loops, subprograms, integers and packages.

## External effects

- **terminal control** (not allowed): Playable game needs raw, non-blocking keystroke input (left/right, hard drop, rotate) and screen redraw/cursor control.
- **clock** (not allowed): Pieces fall over time, so gravity timing needs elapsed time.
- **delay** (not allowed): Frame pacing between game ticks.
- **console output** (allowed): Board and preview piece rendered as text art.

Assessed on 2026-10-15 against page revision 414987 of the [task](https://rosettacode.org/wiki/Tetris) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
