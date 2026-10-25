# Selectively replace multiple instances of a character within a string

**Candidate: proofs likely to discharge automatically.** Every index comes from a for loop over the string's own range and the counter is bounded by the string length, so all checks follow from types and loop bounds with no annotations needed. The program has no recursion, heap use or user input.

Position 490 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed "abracadabra" as a constant String and copy it into a fixed-length String variable Result. Replace is a procedure with parameters Letter, Occurrence (a Positive subtype), the replacement By and the String Result. It uses a for loop over the string's own index range with a Natural counter of matches seen, and on reaching the Occurrence-th match it overwrites that position and stops with an explicit flag. Missing occurrences leave the string unchanged, which is the task's specified outcome, and the program prints the source, " => " and the result. About 35 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the source and result strings with Put_Line.

Assessed on 2026-10-15 against page revision 413011 of the [task](https://rosettacode.org/wiki/Selectively_replace_multiple_instances_of_a_character_within_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
