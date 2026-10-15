# Numerical and alphabetical suffixes

**Candidate: proofs plausibly discharge automatically.** Exact arithmetic in fixed-capacity decimal digit arrays handles the 10^100 and 2^120 multipliers without floating point, and every check follows from digit and carry subtypes plus guards before each shift or append, though the many loop-carried positions need careful shaping.

Position 1413 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Embed the 27 test strings in a constant array of bounded strings; a procedure scans each, strips commas, reads sign, mantissa digits and optional exponent into a fixed-capacity decimal digit array with a scale, then repeatedly applies suffix multipliers (named words matched case-insensitively with minimum abbreviations, metric letters with optional i, or counted factorial steps) via digit-wise multiply-by-small-integer and multiply-by-power-of-ten shifts. Results are printed exactly as comma-grouped integer part plus trimmed fraction, with every index and capacity use guarded and overflow producing a specified rejection message. About 330 lines.

## Proof obligations to watch

- **overflow**: Fixed-capacity decimal digit arrays carry through multiply-by-small-factor loops, so each digit-times-multiplier-plus-carry is kept in range by digit and carry subtypes bounded by the multiplier (at most 1728 or 10) and an explicit overflow check that rejects results exceeding capacity.
- **index**: Digit positions for decimal-point shifts, exponent scaling and comma insertion are computed values, so each is guarded by a comparison against the buffer bounds before use, with a visible Reject-style outcome on overflow.
- **range**: Exponent digits are accumulated in a loop and must be clamped by a guard (reject beyond a small limit) since no invariant can bound the accumulator.
- **termination**: All parsing and arithmetic loops live in procedures or are for loops over the buffer range, so no variant is needed.
- **length**: Output lines are built in a bounded String buffer sized for the longest result (about 120 digits with commas and fraction), with length guards before each append.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, unconstrained arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Prints each input list line and its expanded result line with Put_Line.

Assessed on 2026-10-15 against page revision 412945 of the [task](https://rosettacode.org/wiki/Numerical_and_alphabetical_suffixes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
