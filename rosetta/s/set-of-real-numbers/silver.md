# Set of real numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over fixed-capacity interval arrays with comparison-only arithmetic, so the checks come from types and capacity guards, but the difference and intersection logic needs careful shape to keep counts within capacity without invariants. No recursion, while loops or annotations are needed, and the optional sin-based extra can be replaced by the exact interval rule.

Position 1201 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Represent a real set as a fixed-capacity array of intervals (record with low, high, and open/closed flags for each end, using a scaled-integer or bounded-range subtype for endpoints), plus a count. Membership is a for loop over the intervals with explicit comparisons; union concatenates, intersection pairs and clips intervals, and difference splits intervals around each subtrahend, all inside procedures with capacity guards that report overflow of the limit. Test cases are embedded and printed with Put_Line using a small helper to render integers and Booleans. About 170 lines.

## Proof obligations to watch

- **floating point**: Interval endpoints are compared as bounded Float values (or scaled integers) with no arithmetic beyond comparisons, so only range-constrained subtypes are needed and infinities are modelled by explicit flags or sentinel enumeration values.
- **index**: A set is a fixed-capacity array of intervals with a count; union, intersection and difference append in for loops and a capacity guard rejects results that would exceed the limit with a visible outcome.
- **overflow**: The optional length of A minus B uses sin and a fine sampling loop with a float accumulator, which is avoided by computing the length exactly from the n+1/6 to n+5/6 interval rule with scaled integers, which stays within declared ranges.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, enumerations, arrays, records, for loops, case statements, functions, procedures, 'Image of scalars, string building, Put without a newline and floating point.

## External effects

- **console output** (allowed): Prints membership test results and the empty-set check as text lines.

Assessed on 2026-10-15 against page revision 414464 of the [task](https://rosettacode.org/wiki/Set_of_real_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
