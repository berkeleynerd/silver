# Determine if a string is collapsible

**Candidate: proofs plausibly discharge automatically.** All checks reduce to a bounded Len subtype with an explicit guard before each append, so no annotation is needed, but the loop-carried index and the unconstrained String parameter and slices make it depend on careful program shape rather than being routine.

Position 1079 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A procedure Collapse takes an input String (at most 72 characters, otherwise it rejects with a visible message) and fills a local String (1 .. 72) buffer, with a Len subtype 0 .. 72 updated in a for loop over the input's range. A character is appended only when Len = 0 or it differs from Res(Len), guarded by Len < 72 before the increment. The main procedure calls Collapse on the five embedded strings and prints each original and collapsed string with its length through Put_Line using Integer'Image. About 55 lines.

## Proof obligations to watch

- **index**: Reading Res(Len) and writing Res(Len+1) in a loop-carried Len is discharged by declaring Len as a subtype 0 .. 72 and guarding Len < 72 before each append, with an else branch that rejects the over-long input visibly.
- **overflow**: Len + 1 is safe only because the guard Len < 72 sits immediately before it, since without an invariant GNATprove knows only Len's type range after the first iteration.
- **length**: Slicing Res(1 .. Len) and concatenating the bracketed output string depend on Len's subtype bound and on concatenation of at most 72 characters plus fixed text, which stays well within Natural.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, for loops and procedures.

## External effects

- **console output** (allowed): Prints each original and collapsed string with its length, bracketed by <<< and >>>, through Put_Line.

Assessed on 2026-10-15 against page revision 415398 of the [task](https://rosettacode.org/wiki/Determine_if_a_string_is_collapsible) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
