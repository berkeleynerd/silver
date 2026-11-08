# Read a configuration file

**Candidate: proofs plausibly discharge automatically.** Every access is a bounded index into an embedded constant or fixed buffer, so guards before each use discharge the checks and no invariant is needed, but the many loop-carried positions make the proof depend on careful program shape.

Position 569 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The configuration text is embedded as a String constant with line-feed separators and is scanned by a procedure that splits it into lines, skips blank lines and lines starting with '#' or ';', and splits each remaining line into an upper-cased option name, an optional '=' dropped, and trimmed comma-separated parameters. Results go into fixed-capacity buffers (fullname, favouritefruit, an array of at most a few otherfamily entries with lengths) plus Boolean flags for needspeeling and seedsremoved, and an oversized line or value sets a visible rejection outcome. Main then prints each variable with Put_Line, using if statements for the Boolean text. About 130 lines.

## Proof obligations to watch

- **index**: Scanning positions and slice bounds are loop-carried, so each is clamped to the line's range by an explicit guard immediately before every character access and slice.
- **length**: Option values and parameters are copied into fixed-capacity buffers with a stored length, and a value longer than the capacity is rejected visibly rather than truncated.
- **termination**: All scanning loops are while loops inside procedures, which get no termination check, while any function stays loop-free or uses for loops only.
- **range**: Line-start and line-end positions advance in a while loop, so they are held in subtypes bounded by the embedded text length and checked before each increment.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the four variables and the two otherfamily entries with Put_Line.

Assessed on 2026-10-15 against page revision 412992 of the [task](https://rosettacode.org/wiki/Read_a_configuration_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
