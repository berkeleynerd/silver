# Colorful numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded subtypes and for loops, but the loop-carried product and table index need guards placed just before use, so discharge depends on careful program shape without any annotation.

Position 418 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A function Is_Colorful takes a number in subtype 0..98_765_432, rejects it outright if it is above 9 and has more than 8 digits, extracts digits into a fixed array of 8 with a for loop using mod and /, rejects digits 0 or 1 or repeats, then computes every consecutive-group product with nested for loops into a 36-element array, checking duplicates by linear scan with guards before each multiplication. A main for loop over 0..98_765_432 prints those below 100, tallies counts per digit length, and tracks the largest and total, then prints them with 'Image-built strings. About 130 lines.

## Proof obligations to watch

- **overflow**: The running digit product is loop-carried so GNATprove knows only its subtype, and it discharges only if the product is kept in a bounded subtype and an explicit guard before each multiplication rejects (as not colorful) any value that could exceed the bound, which never fires for distinct digits 2..9.
- **index**: The products table index is a loop-carried counter, so it is held in a subtype sized for the 36 possible products and guarded before each store.
- **termination**: Digit extraction by repeated division is written as a for loop over at most 8 positions, so no variant is needed and the search over 0..98765432 is a for loop in a procedure.
- **range**: Counts and the total (57256) are kept in subtypes with ample range, and the per-number digit array is indexed only by for-loop indexes over its own range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The list of colorful numbers below 100, the per-digit-count tallies, the largest colorful number and the total are printed.

Assessed on 2026-10-15 against page revision 414797 of the [task](https://rosettacode.org/wiki/Colorful_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
