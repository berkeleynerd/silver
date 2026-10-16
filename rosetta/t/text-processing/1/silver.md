# Text processing/1

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded integers (thousandths) with guards before indexing and division, and loops are for loops or while loops in procedures, so nothing needs an annotation, though parsing and decimal formatting with loop-carried values is shape-sensitive.

Position 1148 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

Embed the sample rows as String constants and parse each into a date, 24 integer-thousandth values and 24 flags held in ranged arrays, rejecting malformed rows with a visible message. A for loop over the 24 slots accumulates the valid sum, valid count and current/longest gap run in ranged subtypes, then prints per-line count, sum and the mean computed with integer division as a fixed three-decimal string. A final summary reports total valid readings, overall mean, and the longest gap with its start date, with a count-zero guard before each division. About 170 lines.

## Proof obligations to watch

- **index**: The parser reads characters of each embedded line by position, so every index is guarded by a bound test against the line length just before use.
- **overflow**: Values are held as integer thousandths in ranged subtypes and sums over at most a few hundred readings stay within 64 bits, but each digit accumulation needs a guard on the running value since no invariant exists.
- **division**: The mean divides by the count of valid readings, so a guard on count greater than zero precedes it and the zero case prints a visible 'no valid data' outcome.
- **termination**: Parsing and scanning use while loops only inside procedures, which get no termination check, and the pure functions use only for loops.
- **length**: Formatted output lines are built in a fixed-capacity buffer sized for the longest date, count and decimal text, with a capacity check before each append.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Per-line statistics and the final summary are printed with Put_Line and Put.

Assessed on 2026-10-15 against page revision 413944 of the [task](https://rosettacode.org/wiki/Text_processing/1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
