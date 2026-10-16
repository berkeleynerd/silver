# Sylvester's sequence

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation because all loops are for loops in procedures over fixed-size digit arrays, but terms reach about 10^104 and the fraction about 10^208, so a fixed-capacity decimal bignum with nested-loop multiplication is needed and discharge depends on careful guards and bounded carry types.

Position 1025 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Represent each number as a fixed-capacity little-endian array of about 220 base-10 digits (subtype 0..9) and compute s(n+1) = s(n)*(s(n)-1)+1 with a schoolbook multiply procedure plus decrement and increment procedures, printing each of the 10 terms via a procedure that trims leading zeros into a bounded String. The exact reciprocal sum is 1 - 1/P where P = s(11) - 1 is the product of the ten terms, so the program prints "(P-1)/P" using the same big-number procedures and decimal output; all loops are for loops over the arrays' own ranges, with guards on the i+j column index. About 130 lines.

## Proof obligations to watch

- **index**: Schoolbook big-by-big multiplication indexes column i+j, which is discharged by a guard that i+j stays within the fixed digit capacity (about 220 digits), with overflow of the product treated as a visible reject outcome that never occurs for ten terms.
- **overflow**: Column accumulators and carries are loop-carried but typed as a bounded range (digit products at most 81 per pair, summed over at most a few hundred pairs), so type ranges rather than invariants bound them.
- **range**: Decimal digit values and Character'Val(48 + d) need digits to be a subtype 0..9, which the carry normalisation (mod 10, / 10) must establish for each stored digit.
- **length**: The output buffer for a number must be sized for the maximum digit count (about 210) and the trimmed leading-zero slice computed with a guard so the length is never negative.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, string building, string indexing, unconstrained arrays and Put without a newline.

## External effects

- **console output** (allowed): Prints the ten terms and the exact fraction (P-1)/P of the reciprocal sum to standard output.

Assessed on 2026-10-15 against page revision 414538 of the [task](https://rosettacode.org/wiki/Sylvester's_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
