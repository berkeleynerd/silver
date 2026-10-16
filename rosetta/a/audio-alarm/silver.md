# Audio alarm

**Excluded from Silver: delay, sound.** The Silver-friendly solution reads a bounded integer of seconds and a bounded file name from standard input, validates both with explicit guards that reject bad input with a visible message, prints a text line in place of the blank page, delays, and then plays the named MP3 through an admitted audio library operation. Nothing in the task requires recursion, exceptions, annotations or unsafe constructs, so no conflict is raised; the audio playback and file read are effects Silver lacks today.

## Language surface recorded by this assessment

Integers and string operations.

## External effects

- **standard input** (allowed): Reads the delay in seconds and the MP3 base name typed by the user.
- **console output** (allowed): Prompts for input and prints a text line in place of the blank display page.
- **delay** (not allowed): Waits the requested number of seconds before the alarm sounds.
- **files** (allowed): Names an MP3 file in the app folder, which must be read to play it.
- **sound** (not allowed): Plays the MP3 audio alarm through the audio output device when the delay expires.

Assessed on 2026-10-15 against page revision 414766 of the [task](https://rosettacode.org/wiki/Audio_alarm) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
