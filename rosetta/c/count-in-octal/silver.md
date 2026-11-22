# Count in octal

**Candidate: proofs likely to discharge automatically.** Every check follows from Natural and Integer types and for loops over fixed ranges with no loop-carried value needing an invariant, and the digit buffer of 11 characters holds Integer'Last in octal (17777777777), so the program should prove without annotations.

Position 488 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Loop I over 0 .. Integer'Last (the maximum of the numeric type in use, as the task allows); for each I copy it into a Natural, fill an 11-character String buffer from the right with the octal digits using rem 8 and / 8 over a fixed for loop, and record the first nonzero position (defaulting to the last digit so zero prints as 0). Then print the slice from that position with Silver_IO.Put_Line, one number per line. About 30 lines.

## Proof obligations to watch

- **range**: Each digit is Character'Val (48 + N rem 8) where N is a Natural, so the digit is bounded to 0..7 by the type and the Character range check discharges.
- **index**: The digit buffer is a fixed 11-character String indexed by a for loop over its own range, and the start-of-number index is found by a for loop over the same range, so index checks follow from the loop bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, string building, string indexing and for loops.

## External effects

- **console output** (allowed): Prints one octal number per line to standard output.

Assessed on 2026-10-15 against page revision 413144 of the [task](https://rosettacode.org/wiki/Count_in_octal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
