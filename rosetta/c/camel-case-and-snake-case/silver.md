# Camel case and snake case

**Candidate: proofs likely to discharge automatically.** Everything is bounded character-by-character string processing in procedures with for loops and explicit capacity guards, so all index, range and overflow checks follow from types and guards just before use. The main work needed is Silver growing character, string indexing, slices, unconstrained String parameters and procedures.

Position 994 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Samples are String constants embedded in the program (the non-ASCII sample is kept as its bytes, treated as ordinary characters outside the upper-case, digit and separator classes). A procedure Show takes an unconstrained String, finds the trimmed bounds with while loops, then two conversion procedures fill a fixed 128-character buffer through a guarded position counter and return a length, with the guard rejecting input longer than 64 characters. Character classification uses small Boolean functions with plain comparisons and lower/upper conversion uses 'Pos and 'Val arithmetic, and results print via Put_Line of concatenated slices. About 130 lines.

## Proof obligations to watch

- **index**: The output write position advances by up to two per input character, so each write is preceded by a capacity guard on a Natural-range position that rejects overlong input visibly instead of relying on an invariant.
- **overflow**: Position counters are subtypes bounded by the buffer capacity and are incremented only after a guard, so no overflow or range check depends on loop-carried facts.
- **length**: Input length is checked against a fixed maximum before conversion, and the result is shown as a slice 1 .. Len of the buffer, whose bound follows from the guarded type of Len.
- **termination**: Trimming uses while loops inside procedures, which get no termination check, and the conversion loops are for loops over the input range.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, unconstrained arrays, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each embedded sample and its snake case and camel case conversions with Put_Line.

Assessed on 2026-10-15 against page revision 412003 of the [task](https://rosettacode.org/wiki/Camel_case_and_snake_case) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
