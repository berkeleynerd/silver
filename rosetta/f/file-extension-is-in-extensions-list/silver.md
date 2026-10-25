# File extension is in extensions list

**Candidate: proofs likely to discharge automatically.** Every check follows from a length guard before indexing and for loops over the extension's own range, no loop-carried value needs an invariant, and functions contain only terminating for loops.

Position 981 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the test filenames and the extension list (including tar.bz2, so the extra credit is met) as string literals and call a side-effect-free Ends_With function per extension via a Matches function that checks length > ext length + 1, then that the character before the suffix is a dot, then compares the suffix character by character through a for loop with a small ASCII Lower function (Character'Pos arithmetic), using a Boolean accumulator that cannot fail any check. A procedure Report(Name) ORs the results across the fixed extensions with if statements and prints the filename and True or False via Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: The suffix comparison indexes the filename at offsets from its last character, which is discharged by an explicit guard that the filename is longer than the extension plus the dot and a for loop over the extension's own range.
- **overflow**: Index arithmetic from Name'Last and Ext'Length is safe because the preceding length guard bounds the offset, with String indexes limited to Positive.

## Language surface recorded by this assessment

Boolean objects, characters, string indexing, unconstrained arrays, for loops, functions, procedures, integers and ranged subtypes.

## External effects

- **console output** (allowed): Each test filename and its true/false result is printed with Put_Line.

Assessed on 2026-10-15 against page revision 412792 of the [task](https://rosettacode.org/wiki/File_extension_is_in_extensions_list) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
