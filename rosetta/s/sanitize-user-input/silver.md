# Sanitize user input

**Candidate: proofs likely to discharge automatically.** Every check follows from fixed array and buffer bounds, for loops over a string's own range, and an explicit length guard whose outcome (rejection with a counted message) is visible, so no loop-carried value needs an invariant. The task needs no recursion, while loops or heap, and the hostile data are just embedded constants.

Position 992 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Twenty first/last name pairs are embedded as String constants, ten ordinary and ten hostile, where the hostile ones build NUL, CR, LF and UTF-8 bytes with Character'Val concatenation and include SQL and rm -rf text. A pure function scans each name with a for loop over its range and accepts only ASCII letters plus apostrophe and hyphen with nonzero length at most 32. A Store procedure copies accepted pairs into a Person record array with a length field, while rejected names only increment a counter, and the program prints accepted names and both counts. About 110 lines.

## Proof obligations to watch

- **index**: Copying a validated name into its fixed 32-character record buffer is guarded by an explicit length check that rejects over-long names, and character scans are for loops over the string's own range.
- **initialization**: Each Person record and its buffers are fully blank-filled before partial overwrite so out-parameter and array initialization checks discharge.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, for loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the accepted names and the accepted and rejected counts with Put_Line.

Assessed on 2026-10-15 against page revision 392800 of the [task](https://rosettacode.org/wiki/Sanitize_user_input) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
