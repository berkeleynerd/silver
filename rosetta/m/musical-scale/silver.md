# Musical scale

**Candidate: proofs likely to discharge automatically.** All values and indexes are bounded by static ranges and a for loop over a fixed 8-note array, and no floating point is used because MIDI encodes 12TET pitch by note number, so only the file-write operation is new and the checks are routine.

Position 1420 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Embed the 8 MIDI note numbers (60,62,64,65,67,69,71,72) in a constant array of a byte subtype (0 .. 255), and fill a fixed 90-element byte buffer with the MIDI header, a note-on/note-off pair per note, and the end-of-track event, using a for loop whose indexes are computed from the loop variable within static bounds. Then hand the buffer to an admitted binary file-write operation, with a visible error message if the write fails. Pitches are standard 12TET by MIDI definition (note 69 = A440), so no floating point is needed. About 40 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, file output and procedures.

## External effects

- **files** (allowed): Writes a binary Standard MIDI file (permitted by the task for languages that cannot use a sound device) via an admitted file-writing operation with a specified failure outcome.

Assessed on 2026-10-15 against page revision 414903 of the [task](https://rosettacode.org/wiki/Musical_scale) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
