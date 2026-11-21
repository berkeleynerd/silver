# CRC-32

**Candidate: proofs likely to discharge automatically.** Every operation is on modular values or bounded for-loop indexes, so no overflow, range or index check can fail, and no loop-carried fact beyond type ranges is needed. The expected output 414FA339 is a fixed visible result.

Position 1259 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed the 43-character message as a String constant and keep the CRC in an Unsigned_32 modular variable initialised to 16#FFFFFFFF#. An outer for loop over the message range xors in Character'Pos of each byte, and an inner for loop of eight iterations either shifts right by dividing by 2 or does the same then xors 16#EDB88320#, chosen by testing the low bit with mod 2; the result is complemented and rendered into an 8-character buffer from a hex digit constant string. About 35 lines.

## Proof obligations to watch

- **range**: Hex digit lookup converts (crc / 16**k) mod 16 to a 0..15 index, which follows from the modular type range and the constant digit string's bounds.
- **index**: Message bytes are read by a for loop over the constant string's own range, and the output buffer is filled by a for loop over its own fixed 8-character range.

## Language surface recorded by this assessment

Modular types, integer division, ranged subtypes, characters, string indexing, string building, for loops, integers and Boolean objects.

## External effects

- **console output** (allowed): Prints the checksum as eight hexadecimal digits with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414789 of the [task](https://rosettacode.org/wiki/CRC-32) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
