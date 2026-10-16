# Playfair cipher

**Candidate: proofs likely to discharge automatically.** Everything is bounded array and character work whose indexes follow from small subtypes and capacity guards, with no recursion or functions needing variants, so proofs should discharge routinely.

Position 1446 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Keyword and message come from the first argument and an embedded example, with a Boolean (or enumeration) selecting J=I versus no-Q. A 5x5 Character table is built with a used-letter Boolean array and a letter-position array; text is cleaned into a fixed-capacity buffer (non-letters dropped, X inserted between doubles, padded to even length) and then encrypted and decrypted by digraph loops with row, column and rectangle rules, printed as space-separated pairs. All loops are for loops or procedure while loops with bounded counters, and input longer than capacity or an empty cleaned message is rejected visibly. About 150 lines.

## Proof obligations to watch

- **index**: Cleaned-text buffer writes (doubling for inserted X, plus padding) are guarded by a capacity test that rejects over-long input, with the buffer sized at twice the input limit plus one.
- **range**: Letter-to-row/column lookups use a 1..5 subtype and a position array indexed by letter, so wraparound is computed with explicit if guards rather than mod on unbounded values.
- **initialization**: The table and used-letter arrays are fully initialized by aggregates before the fill loop, and the fill count is guarded so the table is complete before any lookup.

## Language surface recorded by this assessment

Ranged subtypes, characters, enumerations, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, case statements, procedures, functions, Boolean objects, integers, integer division, further arguments and Put without a newline.

## External effects

- **console output** (allowed): Prints the 5x5 table and the encrypted and decrypted digraph text.
- **arguments** (allowed): Keyword and the J=I or no-Q choice could be taken from command-line arguments, with invalid values rejected.

Assessed on 2026-10-15 against page revision 414403 of the [task](https://rosettacode.org/wiki/Playfair_cipher) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
