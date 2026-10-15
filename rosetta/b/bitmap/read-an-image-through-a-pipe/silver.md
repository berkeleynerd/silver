# Bitmap/Read an image through a pipe

**Excluded from Silver: processes.** The task needs a delegate process to convert a foreign image to PPM, whose output is parsed into a bounded bitmap array (header validation, bounded dimensions, pixel records). That is a process/pipe effect plus ordinary SPARK data handling, so no fixed Oracle rule is broken.

## Language surface beyond today's Silver

Arrays, records, loops, subprograms, integers, characters and string operations.

## External effects

- **processes** (not allowed): The task requires running a delegate tool (cjpeg or ImageMagick convert) and reading its PPM output through a pipe.
- **files** (allowed): The foreign image file is read by the delegate tool; PPM data may be read from the pipe or an intermediate file.
- **arguments** (allowed): The input image file name is most naturally supplied as a command-line argument.

Assessed on 2026-10-15 against page revision 410688 of the [task](https://rosettacode.org/wiki/Bitmap/Read_an_image_through_a_pipe) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
