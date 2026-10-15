# Record sound

**Excluded from Silver: hardware, delay.** The Silver-friendly solution records a fixed number of 16-bit mono samples into a bounded array (a documented resource limit) using a loop, then writes them as raw PCM to a file. Only the audio capture device is an effect Silver lacks; the task has no run-time error, exception, annotation or outside-SPARK requirement, so it is a feature and effect gap rather than an Oracle conflict.

## Language surface beyond today's Silver

Integers, arrays and loops.

## External effects

- **hardware** (not allowed): Recording requires capturing audio from a microphone or capture device, which Silver has no access to.
- **delay** (not allowed): The recording runs for a fixed duration (the existing solution uses 10 seconds), so the program must wait while samples are captured.
- **files** (allowed): The recorded 16-bit PCM samples are written to a named output file (the task allows a file instead of memory).

Assessed on 2026-10-15 against page revision 376870 of the [task](https://rosettacode.org/wiki/Record_sound) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
