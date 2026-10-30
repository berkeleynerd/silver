# Knuth's power tree

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic over bounded arrays with for loops, so checks follow from subtypes and guards, but the nested carry loops in bignum multiplication and the tree construction need careful range shaping. No annotation is required, hence plausible rather than likely.

Position 1384 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Build Knuth's power tree iteratively level by level in a Parent array over 1..191 using bounded for loops, and print the addition-chain exponents needed for 0..17 and 191. Then compute powers by walking the chain with a record-wrapped fixed-capacity base-10^4 digit array (multiply, square), producing 2^0..2^17, 3^191 and exactly 11^81 shown as 1.1^81 by inserting the decimal point in a bounded text buffer. All arithmetic sits in procedures with ranged subtypes and explicit capacity guards. About 210 lines.

## Proof obligations to watch

- **overflow**: Bignum multiplication carries a loop-carried carry and product through nested loops, so digit and carry subtypes (base 10^4 digits, carry at most the base) must bound every intermediate in Long_Long_Integer without an invariant.
- **index**: Digit index i+j in the schoolbook product must be guarded against the fixed capacity (about 100 digits) and a visible overflow outcome reported, not silently truncated.
- **range**: Tree construction computes child = node + path element, which must be guarded against the maximum exponent 191 before indexing the parent array.
- **termination**: All loops are for loops or live in procedures, so no variant is needed, though the path walk to the root must be a bounded for loop with an early exit guard.
- **floating point**: Avoided by computing 1.1^81 exactly as 11^81 over 10^81 in the fixed-capacity bignum and printing the decimal point by string building.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, records, big numbers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the power-tree exponent list and each computed power as text lines.

Assessed on 2026-10-15 against page revision 414293 of the [task](https://rosettacode.org/wiki/Knuth's_power_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
