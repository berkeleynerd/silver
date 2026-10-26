# Reverse a string

**Candidate: proofs likely to discharge automatically.** Every index and arithmetic check follows from static string bounds and a for-loop over the array's own range, so the checks discharge without annotations; the Unicode combining-character extra credit is optional and omitted.

Position 470 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed "asdf" as a String constant with static bounds 1..4, declare a same-length String variable initialised with a placeholder aggregate, and run a for loop over the source's own index range copying Source (I) into Result (Source'Last - I + Source'First) before printing it. The mirrored index is always in range because I is bounded by the constant's static bounds, so no guard or loop invariant is needed. About 14 lines.

## Language surface recorded by this assessment

Integers, characters, string indexing, for loops and arrays.

## External effects

- **console output** (allowed): The reversed string is printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415531 of the [task](https://rosettacode.org/wiki/Reverse_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
