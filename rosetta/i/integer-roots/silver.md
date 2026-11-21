# Integer roots

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation because all loops are for loops over fixed digit ranges in procedures and every arithmetic value is bounded by the digit type, but the nested big-number multiplication inside the search loops makes discharge depend on careful program shape. The needed big-number support (digit arrays, multiply, compare, print) is a sizeable new surface.

Position 1369 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent numbers as fixed-capacity little-endian decimal digit arrays with a documented capacity, embed X for the three examples, and compute the root digit by digit from the most significant position, trying digits 9 down to 0 and keeping the largest whose N-th power (repeated big multiplication into a bounded result with an overflow flag) is at most X. Control flow is entirely for loops inside procedures, with guards on product indices and an explicit overflow outcome, and results are printed by converting digit arrays to a bounded String with leading zeros skipped. About 130 lines.

## Proof obligations to watch

- **overflow**: Schoolbook big-by-big multiplication accumulates digit products and carries in loops, so digits are a small ranged subtype and each partial sum is kept below base*base*capacity+base, which fits Integer from the types alone.
- **index**: Product positions i+j are checked against the fixed capacity by a guard before each write, and a product exceeding capacity sets an overflow flag that is reported as a visible rejection rather than dropped.
- **range**: Each carry-derived digit is reduced with mod before storing into the ranged digit subtype, which provers handle given the bounded operands.
- **termination**: Only for loops and procedures are used (digit-by-digit search from the top position with trial digits 9 down to 0), so no variant is needed.
- **other**: The task's no-arbitrary-limits clause is met only as an explicit documented fixed capacity (for example 64 digits for the 38-digit example), and the optional 2001-digit example would need a much larger capacity that makes the nested loops heavier for the provers.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, unconstrained arrays, for loops, procedures, functions, Boolean objects, big numbers, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the three example results (cube roots of 8 and 9, square root of 2*10^38) as text lines.

Assessed on 2026-10-15 against page revision 406156 of the [task](https://rosettacode.org/wiki/Integer_roots) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
