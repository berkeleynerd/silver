# Image noise

**Excluded from Silver: clock.** The task needs a 320x240 bounded pixel array filled from a deterministic pseudo-random generator, written to an image file, with FPS measured from the clock and printed. No fixed Oracle rule is broken. Bounded loops, fixed-size arrays and modular-integer arithmetic suffice, and a bounded frame count can stand in for running forever.

## Language surface recorded by this assessment

Integers, arrays, loops, subprograms, enumerations and floating point.

## External effects

- **files** (allowed): The task asks for a continuously generated 320x240 black and white noise image with a frame rate shown. It does not require a window. A Silver-friendly solution writes each frame (or a bounded number of frames) as a PBM/PGM image file.
- **console output** (allowed): The frames-per-second figure is printed as text.
- **clock** (not allowed): FPS needs elapsed time measured against a clock.

Assessed on 2026-10-15 against page revision 408697 of the [task](https://rosettacode.org/wiki/Image_noise) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
