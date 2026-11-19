# Time conventions and conversions

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic with constant-table lookups through for loops and no recursion, so checks follow from range subtypes and guards, but careful range sizing, negative floor division and leap-boundary handling make it plausible rather than likely.

Position 476 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Timestamps are 64-bit integers in microseconds held in declared range subtypes, with the 28-entry leap-second table and the table's example data embedded as constant arrays. Conversions are range-checked functions (days-from-civil and civil-from-days using integer division, epoch offset shifts, a for-loop table lookup for the leap-second offset), and a procedure formats each row with bounded String buffers and 'Image, printing via Put and Put_Line. Out-of-domain timestamps are rejected with a visible message rather than clamped. About 260 lines.

## Proof obligations to watch

- **overflow**: Microsecond timestamps (about 5e15 at most) and day-count arithmetic fit in a 64-bit declared range type, with year, month, day and offset subtypes bounding every operand so products cannot overflow.
- **range**: Floor division and mod of negative pre-epoch values, and the civil-date-from-days algorithm, need range-typed intermediates and a guard on the timestamp domain, with out-of-domain inputs given a visible rejection message.
- **index**: The leap-second lookup is a for loop over the table's own index range, and the offset it carries is a subtype 0..37, so no invariant is needed.
- **other**: Inverse TAI/GPS to UTC conversion at a leap-second boundary is ambiguous (two TAI seconds map to the same UTC label), so the program must choose and document a deterministic mapping that reproduces the required table.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the filled-in conversion table to standard output.

Assessed on 2026-10-15 against page revision 372085 of the [task](https://rosettacode.org/wiki/Time_conventions_and_conversions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
