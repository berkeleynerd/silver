# Audio overlap loop

**Excluded from Silver: sound.** The required core is a repetition-count argument, reading loop.wav, and playing it several times with overlap. Playback is an external sound effect Silver lacks, not a fixed-rule conflict. Delay and decay are optional and omitted, so floating-point and timing effects are not needed. Bounded sample arrays and integer mixing cover the overlap.

## Language surface recorded by this assessment

Arrays, integers, loops and subprograms.

## External effects

- **arguments** (allowed): The program takes the repetition count as a command-line parameter.
- **files** (allowed): The program reads the sample file loop.wav, which is a WAV audio file, and parses its header and samples.
- **sound** (not allowed): The task says to play loop.wav in an overlapping loop, so audio output is required. Writing a mixed WAV file instead would change the task's stated behavior, so it is not the chosen solution.

Assessed on 2026-10-15 against page revision 398502 of the [task](https://rosettacode.org/wiki/Audio_overlap_loop) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
