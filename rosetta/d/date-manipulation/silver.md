# Date manipulation

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer and string work with guards before each index and rollover step, so the checks should discharge without annotations, though the parser and calendar rollover need careful shape; no task requirement conflicts with the Oracle.

Position 1132 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the input string "March 7 2009 7:30pm EST" as a constant and parse it with a bounded while loop in a procedure, matching the month name against a constant table and reading digit fields with capped digit counts, rejecting malformed input visibly. Convert to 24-hour time, add 12 hours with explicit day, month and year rollover (days-in-month table plus leap-year test), then print the result in EST and in a second zone (UTC, a fixed +5 hour shift using the same rollover procedure) via bounded string building. About 130 lines.

## Proof obligations to watch

- **index**: The hand-written parser steps through the embedded string with a position variable, so each access is guarded by a position-less-or-equal-Last test just before it, and any malformed field takes a visible reject path.
- **overflow**: Digit accumulation for day and year is loop-carried, so the loop stops after a fixed maximum digit count (4 for the year, 2 for the day) so the type range bounds the value without an invariant.
- **range**: Adding 12 hours rolls over the day, month and year using range-guarded comparisons against a days-in-month table with a leap-year test, so each result is checked against its subtype before assignment.
- **length**: The output line is built by bounded concatenation of fixed-width fields (zero-padded numbers, month name from a constant table) into a buffer sized for the longest possible result.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the original time and the time 12 hours later, in EST and in a second zone such as UTC, to standard output.

Assessed on 2026-10-15 against page revision 414742 of the [task](https://rosettacode.org/wiki/Date_manipulation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
