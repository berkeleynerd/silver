# Strip comments from a string

**Candidate: proofs likely to discharge automatically.** Every check is an index or slice bound derived from for-loop indexes over the string's own range, and there are no function loops, recursion or arithmetic beyond small index steps, so proofs should discharge unaided. The program must trim whitespace (the current task rules), which is done with simple for loops rather than a loop-carried while scan.

Position 1046 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The two example lines are embedded as String constants and passed to a procedure Strip_And_Print taking an unconstrained String. It uses a for loop over Line'Range to find the first '#' or ';' (recording the cut position, defaulting to the end), then a forward for loop to find the first non-blank and a reverse for loop to find the last non-blank within the kept prefix, and prints the slice if non-empty or an empty line otherwise. All loop-carried positions are assigned only from loop indexes, so slice bounds are always valid and no while loop is needed. About 40 lines.

## Proof obligations to watch

- **index**: The first and last kept positions are only assigned from for-loop indexes over Line'Range, so slice bounds stay within the string without an invariant.
- **overflow**: Line'First and Line'Last arithmetic such as I - 1 is guarded by comparing I to Line'First, or avoided by using slices keyed to loop indexes.

## Language surface recorded by this assessment

Integers, characters, string indexing, unconstrained arrays, for loops, procedures and ranged subtypes.

## External effects

- **console output** (allowed): The stripped result lines are printed with Put_Line.

Assessed on 2026-10-15 against page revision 414667 of the [task](https://rosettacode.org/wiki/Strip_comments_from_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
