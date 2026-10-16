# Hex dump

**Candidate: proofs likely to discharge automatically.** Every index, division and range check follows from the embedded array bounds, the byte subtype and guards placed before each use, and the only loop-carried arithmetic is the guarded argument parsing, so the proofs should discharge without annotations. The program needs no function loops or recursion, only procedures and for loops.

Position 1445 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

The 104 UTF-16 example bytes are an embedded constant array of a byte subtype 0 .. 255, and the optional offset and length arguments are parsed with guarded digit loops into bounded integers, with invalid text or an offset beyond the data rejected. A for loop over 16-byte rows calls a procedure that writes the 8-digit hex offset, the hex bytes with the extra gap after the eighth, padding for a short last row, and the printable-or-dot character field, all using Put on a constant hex digit table. The final byte count line is printed last, and the binary mode is left out as a stretch goal. About 110 lines.

## Proof obligations to watch

- **overflow**: Parsing offset and length digit by digit carries an accumulator through a loop, so each step is guarded against exceeding a documented maximum and an over-large value is rejected with a visible outcome.
- **index**: Offset and length are checked against the 104-byte embedded array before the for loops index it, and an out-of-range offset is rejected rather than clamped.
- **range**: Hex digit lookups use value / 16 and value mod 16 on a byte subtype 0 .. 255, which stay within the 16-character digit table, and the offset is formatted from a bounded integer type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, string indexing, string building, text parsing, further arguments, Put without a newline and exit status.

## External effects

- **console output** (allowed): The dump lines are written to standard output.
- **arguments** (allowed): Optional start offset and length are read from the command line.

Assessed on 2026-10-15 against page revision 414249 of the [task](https://rosettacode.org/wiki/Hex_dump) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
