# URL encoding

**Candidate: proofs likely to discharge automatically.** Everything is a single for loop over a fixed-length string with bounded byte arithmetic and a capacity guard before each append, so all checks follow from types and guards without any invariant. The only care is keeping the output length counter's growth safe, which the pre-append guard handles.

Position 516 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

A procedure encodes an embedded constant input string such as "http://foo bar/" into a fixed-capacity Character buffer with a length counter, using a for loop over the input's own range. Each character is classified by comparisons (0-9, A-Z, a-z are copied; all others become '%' plus two digits from a constant hex-digit string indexed by Pos/16 and Pos mod 16). A capacity guard before each append rejects input that would overflow the buffer, and the main program prints the result with Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: Output buffer writes are guarded by a capacity check before each append (each input character adds at most 3), and the for loop indexes the input over its own range.
- **range**: The Character'Pos value (0..255) is split into two hex digits by /16 and mod 16 on a bounded subtype, so the digit lookup index is statically within a 16-entry constant table.

## Language surface beyond today's Silver

Characters, ranged subtypes, integers, integer division, string indexing, string building, arrays, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the encoded example string with Put_Line.

Assessed on 2026-10-15 against page revision 411834 of the [task](https://rosettacode.org/wiki/URL_encoding) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
