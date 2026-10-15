# Juggler sequence

**Candidate: proofs plausibly discharge automatically.** The task's 20..39 range is small and its values fit in 64 bits, so every check follows from subtype ranges and guards placed before the multiplication, with only the loop-carried term and square-root search needing careful guards. The optional big-integer part is skipped, and no annotations are needed.

Position 236 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use a 64-bit integer for the current term, with an integer-square-root procedure written as a bounded binary search in a while loop, and a for loop over n in 20..39. For each n a while loop in a procedure steps by isqrt(a) when even or a * isqrt(a) when odd, tracking the step count, the maximum and its first index, with guards that reject on overflow risk or step-cap exceedance. Rows are built as bounded text with 'Image conversions and printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The odd step computes a * isqrt(a) on a loop-carried value, so an explicit guard rejects any odd a above about 4 trillion (never triggered for n 20..39, whose maximum is 2.5e13 and even) to keep the product within 64 bits.
- **range**: The binary-search integer square root has loop-carried lo, hi and mid bounds that must be kept in a narrow subtype, with mid computed as lo + (hi - lo) / 2, so the type ranges alone discharge the checks.
- **termination**: The sequence while loop and the square-root search loop live in procedures, which get no termination check, but a step counter capped by a guard with visible rejection gives a safe bound.
- **floating point**: Avoided entirely by using integer arithmetic (a^1.5 = a * isqrt(a), a^0.5 = isqrt(a)), so faithful floor results need no floating-point proofs.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a table of l[n], h[n] and i[n] for n from 20 to 39.

Assessed on 2026-10-15 against page revision 412865 of the [task](https://rosettacode.org/wiki/Juggler_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
