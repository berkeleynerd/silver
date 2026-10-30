# Sutherland-Hodgman polygon clipping

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over fixed-capacity arrays and the arithmetic is bounded integer math, so checks follow from types plus a few guards (capacity, nonzero denominator, range), though the nonlinear scaled-integer intersection needs careful bounds to discharge. Extra credit graphics are optional and skipped.

Position 621 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Represent points as records of bounded integer coordinates (fixed-point scaled by 100000 so values like 116.66667 print exactly) in fixed-capacity arrays with a count, embedding the subject and clip polygons as constants. Run a nested for loop over the clip edges and the input vertices in a procedure, using an integer cross-product Inside test and a guarded intersection function, appending to a bounded output array with a capacity guard. Print each result vertex by building integer-part and fraction digits into a short string and calling Put_Line. About 130 lines.

## Proof obligations to watch

- **overflow**: Cross-product and intersection arithmetic is nonlinear, but coordinates are a bounded subtype (about 0..1000, scaled by 100000 in Long_Long_Integer) so every product fits within 64 bits.
- **division**: The intersection denominator is not provably nonzero from types, so an explicit zero test precedes the division and a zero denominator leads to a visible rejection message.
- **index**: The output vertex count is loop-carried, so each append is preceded by a guard against the fixed capacity (for example 64) that reports overflow of the limit instead of dropping points.
- **range**: Intersection results computed by division are not provably inside the coordinate subtype, so they are range-guarded before being stored, with rejection if out of range.
- **length**: Decimal text for the fractional coordinates is built in a fixed-size buffer whose maximum length follows from the bounded coordinate range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string building, 'Image of scalars, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the clipped polygon's vertex sequence to standard output.

Assessed on 2026-10-15 against page revision 413077 of the [task](https://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
