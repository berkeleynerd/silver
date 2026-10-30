# Update a configuration file

**Candidate: proofs plausibly discharge automatically.** The task only needs bounded line buffers, character scanning and Put_Line output over embedded data, and every index and length check can be guarded in procedures with bounded loops, but many loop-carried positions make careful guard placement necessary.

Position 634 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The sample file is embedded as a fixed-capacity array of line records (a bounded character buffer plus a length), and one procedure walks the lines, passing lines that start with a hash through unchanged. For other lines it strips semicolons and whitespace and drops control or non-ASCII characters, upper-cases the option word, and compares it with the four known options, keeping only the first occurrence of each. It emits the updated entry (NEEDSPEELING disabled with a semicolon, SEEDSREMOVED enabled, bananas 1024), appends any missing entry such as NUMBEROFSTRAWBERRIES 62000, and prints the result with Put_Line. About 230 lines.

## Proof obligations to watch

- **index**: Scanning for the option word, trimming whitespace and copying parameter text use loop-carried positions, so each access sits behind an explicit bounds guard or a for loop over the buffer's own range.
- **length**: Output lines are built in fixed-capacity buffers with a length counter, so every append is guarded by a capacity check that rejects over-long lines visibly rather than truncating.
- **overflow**: Line counts and buffer lengths are declared ranged subtypes with a capped line count, and the forced values 1024 and 62000 are constants, so counters cannot exceed their ranges.
- **termination**: All loops run in a procedure, using for loops or while loops over bounded positions, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The embedded sample file is rewritten in memory and the revised file is printed line by line with Put_Line.

Assessed on 2026-10-15 against page revision 413956 of the [task](https://rosettacode.org/wiki/Update_a_configuration_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
