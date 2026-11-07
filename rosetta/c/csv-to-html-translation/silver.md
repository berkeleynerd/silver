# CSV to HTML translation

**Candidate: proofs likely to discharge automatically.** "The task is a single pass over a fixed embedded string with a bounded output buffer, so every check follows from for-loop ranges and capacity guards placed before each append. No recursion, exceptions or annotations are required, and the optional thead header row is a simple first-row flag."

Position 769 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

"Embed the CSV text as a constant String, then walk it once with a for loop over its own index range in a procedure. Each character is appended to a fixed-capacity Character buffer through an Append procedure that escapes <, >, & and quotes via a case statement and sets a Boolean overflow flag when capacity would be exceeded; row, cell and table tags are appended at newlines and commas. Finally the buffer is printed line by line, and an overflow is reported as a visible rejection." About 70 lines.

## Proof obligations to watch

- **index**: Scanning for commas and slicing fields uses loop-carried positions, so each access is guarded by a bounds comparison just before use, or iterates a for loop over the embedded text's own range.
- **length**: Escaped output grows up to 5 characters per input character, so the output buffer is sized for the worst case and each append is guarded by a capacity check that rejects visibly when exceeded.
- **range**: The write cursor into the output buffer is a bounded-range counter checked against capacity before each append, since the prover knows only its type after the first iteration.

## Language surface recorded by this assessment

Characters, string indexing, string building, for loops, arrays, ranged subtypes, integers, case statements, procedures, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): The program prints the HTML table to standard output.

Assessed on 2026-10-15 against page revision 414644 of the [task](https://rosettacode.org/wiki/CSV_to_HTML_translation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
