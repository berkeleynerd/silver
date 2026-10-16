# ASCII art diagram converter

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes, fixed-capacity buffers and guards placed before each index, and loops live in procedures, but the many loop-carried positions in the scanner and the validation shape need careful guard placement. No annotation is needed, so discharge is plausible rather than routine.

Position 1313 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

The diagram is embedded as an array of fixed-length row strings, and the parser classifies each row as a border (only plus and minus) or a field row (pipes, letters and spaces), checks that every row has the same column count of 3*N+1 for N in 8, 16, 32 or 64, and records each field's name, start bit and width into a bounded record array from the pipe positions. A sample header, embedded as a hex string, is then decoded into per-field values with a bit-extraction loop over a 64-bit modular accumulator, and the table and values are printed with Put_Line and Put. Any malformed row, bad character, misaligned pipe or capacity overflow gives a visible rejection message. About 170 lines.

## Proof obligations to watch

- **index**: The scanner walks diagram lines by a loop-carried column position, so every String index and every field-table insertion is guarded just before use by a comparison against the line length and the table capacity.
- **overflow**: Field widths and start offsets are held in bounded integer subtypes (at most 64 columns, 64 fields), and the decoded values use a 64-bit modular type so shifts and sums cannot raise a check.
- **termination**: Scanning uses for loops over fixed ranges or while loops inside procedures only, so no function needs a variant.
- **length**: Diagram lines and the output buffer are fixed-capacity bounded buffers, and an oversized, ragged or unrecognised diagram is rejected with a printed message rather than truncated.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the parsed field table and each decoded field value, or the rejection message for an invalid diagram.

Assessed on 2026-10-15 against page revision 414045 of the [task](https://rosettacode.org/wiki/ASCII_art_diagram_converter) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
