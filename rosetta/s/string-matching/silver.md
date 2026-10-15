# String matching

**Candidate: proofs likely to discharge automatically.** All indexing uses constant lengths and for-loop indexes over the string's own range with guards just before slices, and there is no loop-carried arithmetic, so the checks follow from declarations and guards.

Position 962 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed two constant Strings (for example a text with repeated occurrences and a pattern) in Main, and use a length guard with and then before comparing the leading and trailing slices for starts-with and ends-with. For contains, a for loop over the valid start positions compares the slice to the pattern and prints each match location via Integer'Image, handling multiple occurrences with no loop-carried accumulator; an empty pattern is excluded by a visible guard that prints a specified message. About 35 lines.

## Proof obligations to watch

- **index**: Slice bounds I .. I + S2'Length - 1 are discharged because the for loop runs I over 1 .. S1'Length - S2'Length + 1 with static constant lengths, and starts/ends slices are guarded by a length comparison with and then.
- **length**: The output line concatenates fixed-length literals, constants and a short Integer'Image, so its bounded result length is statically known.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, string indexing, unconstrained arrays, for loops, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints the starts-with, ends-with and match-location results with Put_Line.

Assessed on 2026-10-15 against page revision 414521 of the [task](https://rosettacode.org/wiki/String_matching) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
