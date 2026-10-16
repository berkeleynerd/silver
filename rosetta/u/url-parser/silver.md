# URL parser

**Candidate: proofs plausibly discharge automatically.** Every check is an index or range check on slice bounds from loop-found positions, which can each be protected by explicit guards before use, and there are no while loops, recursion or floating point, so no annotation is needed. Discharge depends on careful guard placement across many loop-carried positions, hence plausible rather than likely.

Position 1033 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the task's test URLs as string literals and pass each to a procedure that rejects input longer than a fixed cap or lacking a valid scheme (letters then ':'), printing a specific diagnostic. It scans with for loops over URL'Range to record the first positions of ':', "//", '@', '/', '?' and '#' in bounded Natural variables, then derives scheme, userinfo, domain, port, path, query and fragment as guarded slices and prints each non-empty one with Put_Line, treating bracketed IPv6 hosts as a single domain. About 170 lines.

## Proof obligations to watch

- **index**: Component boundaries are found by for loops recording delimiter positions in loop-carried variables, so each slice is guarded with explicit start and end comparisons against the string's bounds just before use.
- **range**: Position variables use a bounded Natural subtype and the input length is rejected above a documented limit (for example 256), so index arithmetic like pos + 1 cannot overflow.
- **length**: Printed output is built from slices with guarded bounds, and any concatenation is limited by the length cap, so no length check can fail.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, unconstrained arrays, string indexing, for loops, procedures, functions, records, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Each embedded URL and its parsed components or an error diagnostic are printed line by line.

Assessed on 2026-10-15 against page revision 413108 of the [task](https://rosettacode.org/wiki/URL_parser) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
