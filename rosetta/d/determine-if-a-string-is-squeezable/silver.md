# Determine if a string is squeezable

**Candidate: proofs likely to discharge automatically.** Everything is a single bounded for loop over an array with a subtype-bounded counter and one capacity guard, so all checks follow from types and a guard just before the operation; the only added surface is ordinary strings, characters and procedures with no recursion, while loops or annotations.

Position 1048 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A procedure Squeeze takes an unconstrained String and a Character, copies characters into a fixed 72-character buffer with a Natural-subtype length counter, skipping a character only when it equals the specified character and the previously kept one. A for loop over S'Range does the scan, with an explicit capacity guard that rejects, and a main body calls Squeeze seven times on embedded literals and prints bracketed strings and lengths with Put_Line using 'Image. About 45 lines.

## Proof obligations to watch

- **index**: The loop-carried output length has no invariant, so a guard 'Len < Res'Last' before each append (Reject on failure, which is unreachable for real inputs) lets the Res(Len+1) index and Len+1 range checks discharge from the subtype alone.
- **length**: Inputs are capped by a documented 72-character buffer, with a visible Reject outcome for longer strings, so slices Res(1..Len) are provably within bounds.

## Language surface recorded by this assessment

Characters, ranged subtypes, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints the squeezed character, original and result strings in <<< >>> brackets with their lengths for seven test cases.

Assessed on 2026-10-15 against page revision 412743 of the [task](https://rosettacode.org/wiki/Determine_if_a_string_is_squeezable) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
