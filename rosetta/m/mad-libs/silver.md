# Mad Libs

**Candidate: proofs plausibly discharge automatically.** Everything is bounded string and array manipulation in procedures with explicit capacity guards and visible rejection, so no annotations are needed, but index and length checks on loop-carried positions make careful program shape necessary.

Position 1244 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Store the story as a fixed-capacity array of lines, each a bounded String buffer plus a length, read from stdin with a while loop until a blank line or the line cap (over-long lines or too many lines are rejected visibly). Repeatedly scan for the first complete <...> placeholder, prompt for its replacement, read the word into a bounded buffer, then replace every occurrence in all lines by rebuilding each line in a bounded buffer after a capacity guard. When no placeholder remains, print every line with Put_Line. About 130 lines.

## Proof obligations to watch

- **index**: Scanning for '<' and '>' and slicing lines uses loop-carried positions, so each access is guarded by a comparison against the stored line length just before use.
- **length**: Replacing a placeholder can lengthen a line past the fixed capacity, so a guard computes the new length in a wide integer type and rejects the story with a visible message when it would not fit.
- **overflow**: Line counts, lengths and shift offsets are bounded by subtype ranges (e.g. 0..200 lines, 0..1000 characters) so arithmetic on them cannot overflow.
- **termination**: All loops live in procedures, so no termination check applies, and the replace-all scan advances past each replacement so it still finishes in practice.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, standard input, Put without a newline and Boolean objects.

## External effects

- **standard input** (allowed): Reads the multiline story up to a blank line and then one replacement word per placeholder.
- **console output** (allowed): Prompts for each placeholder and prints the final story.

Assessed on 2026-10-15 against page revision 414320 of the [task](https://rosettacode.org/wiki/Mad_Libs) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
