# Bitmap/PPM conversion through a pipe

**Excluded from Silver: processes.** The task needs a bounded in-memory bitmap (an array of RGB pixels) written as PPM to a pipe feeding an external JPEG converter. That is a process and pipe effect Silver lacks today, but no fixed Oracle rule forbids it, so there is no conflict.

## Language surface recorded by this assessment

Arrays, records, loops, subprograms and integers.

## External effects

- **processes** (not allowed): The task requires delegating JPEG encoding to an external utility (cjpeg, ppmtojpeg or convert) by writing PPM data through a pipe to a spawned process.
- **files** (allowed): The converter's JPEG output goes to a file or the process's standard output, so the program needs file output unless the pipe is read back.

Assessed on 2026-10-15 against page revision 411214 of the [task](https://rosettacode.org/wiki/Bitmap/PPM_conversion_through_a_pipe) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
