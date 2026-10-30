# Reverse the gender of a string

**Candidate: proofs plausibly discharge automatically.** The task is a simple single-pass word substitution over a bounded buffer with no recursion or annotations needed, but the loop-carried positions and bounded output need careful guards.

Position 551 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the example sentence in a bounded Character buffer, scan it once in a procedure with a for loop over indexes, identify word boundaries by Character class tests, and when a word equals a pronoun (She/He/Her/His/him/hers etc.) append its replacement to a bounded output buffer, otherwise copy characters. Guard output capacity and reject if the result would not fit, then print with Put_Line; ambiguous words such as her use a fixed documented mapping. About 90 lines.

## Proof obligations to watch

- **index**: Word scanning with a loop-carried position and word boundary lookahead/lookbehind needs explicit guards before each String index, which is feasible but fiddly.
- **length**: Output buffer growth (swaps like he to she lengthen text) is handled by a fixed capacity with a guard that rejects input whose result would exceed it, a visible outcome.
- **overflow**: Loop-carried read and write positions stay within the bounded Natural subtype range, so increments need guards against the capacity.
- **termination**: The scan loops are inside procedures (or for loops over the input range) so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the original and gender-swapped example sentences.

Assessed on 2026-10-15 against page revision 414444 of the [task](https://rosettacode.org/wiki/Reverse_the_gender_of_a_string) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
