# Exponential digital sums

**Candidate: proofs plausibly discharge automatically.** All checks follow from declared subtypes, array bounds and for-loop ranges, with the only nontrivial parts being the carry in the digit-array multiply and the capacity guards. The program is plausible rather than likely because the fixed-capacity big-number arithmetic runs through nested loops and the search limits must be sized so the required outputs fit.

Position 932 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Represent each power as a fixed-capacity array of decimal digits (about 2000 digits) with a length, and compute n^p by repeated small-integer multiplication with a bounded carry in a for loop over the used digits. For each candidate n from 2 up to a fixed limit, loop p from 2 to a fixed exponent limit, compute the digit sum, record each p where the sum equals n in a small bounded array of exponents, and stop early when the digit sum clearly cannot return to n. Two procedures print the first twenty hits and the first ten with at least three exponents, formatting each line with scalar-image into a bounded buffer. About 130 lines.

## Proof obligations to watch

- **overflow**: The multiply-by-base carry is a loop-carried value, so it gets a bounded subtype (0..base limit) and digit*base+carry stays within Integer from the types alone.
- **index**: Growing the digit count while propagating the final carry needs a guard that length is below capacity before each append; a failed guard gives a visible reported-limit outcome, and the capacity is sized so the required outputs never reach it.
- **range**: The running digit sum and per-integer match counters are bounded by subtypes sized to capacity times 9 and to the exponent limit, with guards before increments.
- **termination**: The search over integers and exponents uses for loops or while loops only inside procedures, so no variant is needed.
- **length**: Result lines are assembled in a fixed-size bounded buffer, with a guard before each append so a full buffer is handled visibly rather than silently truncated.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, string building, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the first twenty integers with their exponents and the first ten three-or-more-way integers with their exponents.

Assessed on 2026-10-15 against page revision 413985 of the [task](https://rosettacode.org/wiki/Exponential_digital_sums) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
