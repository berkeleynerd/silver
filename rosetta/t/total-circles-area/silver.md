# Total circles area

**Candidate: proofs plausibly discharge automatically.** Everything is for loops over fixed array ranges with bounded float subtypes, so checks reduce to range and guard facts, but float accumulation, Sqrt and the float-to-integer conversion need careful bounding for the provers.

Position 877 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the 25 circles as constant arrays of centre x, centre y and radius in bounded float subtypes, then integrate the union's vertical cross-section length over x with many midpoint strips (exact, using only Sqrt, not grid sampling). For each strip a for-loop builds each circle's interval, sorts the intervals with a bubble sort made of nested for loops, and sweeps them with a running right end to sum the union length. The area is scaled to an integer, guarded, and printed with Put_Line using integer image and string building of the decimal point. About 120 lines.

## Proof obligations to watch

- **floating point**: Sqrt of r^2-dx^2 and the products and sums over strips need float overflow and non-negative-argument checks, discharged by bounded float subtypes for coordinates and a guard that the sqrt argument is positive.
- **overflow**: The loop-carried area accumulator and interval-end values only have their subtype range after the first iteration, so each must be declared in a bounded float subtype wide enough to hold any sum of strip contributions and clamped by a visible guard.
- **range**: Converting the float area scaled by 1e6 to an integer for printing needs a guard on the magnitude, which the bounded accumulator type provides.
- **floating point**: Reaching six digits requires an exact per-strip union length with roughly 100000 midpoint strips, and the float rounding behavior of that sum is not provable but is only an accuracy concern rather than a check.

## Language surface beyond today's Silver

Floating point, arrays, ranged subtypes, for loops, integers, 'Image of scalars, string building, Boolean objects and functions.

## External effects

- **console output** (allowed): The program prints the computed total area as a line of text.

Assessed on 2026-10-15 against page revision 414552 of the [task](https://rosettacode.org/wiki/Total_circles_area) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
