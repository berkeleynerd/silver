# Play recorded sounds

**Excluded from Silver: sound, delay.** The task needs an audio device to play prerecorded sounds, which Silver lacks, so this is an effect and not a conflict. Loading files, console text and waiting are the other needs. Nothing requires exceptions, annotations, unsafe code or run-time error demonstration; the optional timed-marker and stereo/3D parts are left out. The existing ASFML solution is only evidence, so its foreign binding is not counted as a conflict.

## External effects

- **sound** (not allowed): The task requires playing prerecorded sounds through an audio device, individually and simultaneously, with stop, loop and volume control. Silver has no audio effect today.
- **files** (allowed): At least two prerecorded sound files must be loaded from named files on disk.
- **console output** (allowed): The program should print a description or status text, and the task asks for a written description of the supported formats and suitability.
- **delay** (not allowed): Playback runs over time, so the program must wait between actions (for example, letting a sound play for a few seconds before stopping it).

Assessed on 2026-10-15 against page revision 414767 of the [task](https://rosettacode.org/wiki/Play_recorded_sounds) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
