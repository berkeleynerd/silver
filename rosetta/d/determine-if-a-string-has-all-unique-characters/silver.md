# Determine if a string has all unique characters

**Candidate: proofs likely to discharge automatically.** All checks follow from for-loop indexes over declared bounded ranges and a Pos/16 and mod 16 hex lookup bounded by the Character type, with no loop-carried accumulators and no recursion, while loops or functions needing variants.

Position 969 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A procedure Check takes a bounded string record (a 40-character array and a Length in 0..40), prints it with its length via 'Image, then scans with a nested for loop over I in 1 .. Length-1 and J in I+1 .. Length, comparing characters. On the first match it prints the character, both positions and its two-digit hex value looked up in a constant hex-digit string, then exits by a flag guarding the loops; otherwise it prints that all characters are unique; the main body calls Check on the five embedded test strings. About 55 lines.

## Proof obligations to watch

- **length**: Concatenating the echoed string with text could overflow the index range if the parameter were unbounded, so the program stores each test string in a bounded record (Length 0..40 plus a 40-character buffer) or prints pieces separately with Put, making every length statically bounded.
- **range**: The hex digit lookup uses Character'Pos divided by 16 and mod 16, whose results are bounded 0..15 by the Pos range 0..255, so indexing the constant string "0123456789ABCDEF" discharges from types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, unconstrained arrays, records, string indexing, 'Image of scalars, for loops, procedures, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each test string, its length, and the uniqueness verdict, with duplicate positions and hex value.

Assessed on 2026-10-15 against page revision 414645 of the [task](https://rosettacode.org/wiki/Determine_if_a_string_has_all_unique_characters) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
