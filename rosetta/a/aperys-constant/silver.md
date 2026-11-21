# Apéry's constant

**Candidate: proofs plausibly discharge automatically.** Everything reduces to fixed-capacity limb arrays with small-integer multiply/divide in for loops inside procedures, so checks follow from ranged types and array ranges, but carry bounds, Wedeniwski multiplier sizes and guard-digit truncation require careful shaping.

Position 1393 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent each value as a fixed-capacity array of base-10^4 limbs (integer part plus roughly 30 limbs of fraction with guard digits), with procedures for add, subtract, multiply-by-small and divide-by-small using ranged carries. Compute 1000 terms of 1/k^3 by dividing one by k^3 (at most 1e9) per term, the Markov terms by the recurrence a(k+1)=a(k)*(k+1)/(2(2k+1)) then dividing by k^3, and the Wedeniwski terms by the hypergeometric ratio of consecutive terms times the polynomial, all in for loops. Finally truncate to 100 decimals, convert limbs to characters in a fixed String buffer, and print four lines (the literal constant and the three sums) with Put_Line. About 260 lines.

## Proof obligations to watch

- **overflow**: Limb-by-small-integer multiply and divide carry and remainder values are held in ranged subtypes whose bounds follow from the base and the capped multiplier or divisor, so limb*multiplier+carry fits in 64 bits without a loop invariant.
- **range**: The remainder after mod is known to be below the divisor only if the divisor is a positive ranged parameter, so every divide helper takes a ranged divisor subtype and the caller keeps the Wedeniwski ratio factors and polynomial value within that range.
- **overflow**: Wedeniwski polynomial coefficients times k^5 reach about 4e11 and the ratio factors reach about 1e6, so each is applied as several chained small multiplies or kept in 64-bit ranged subtypes so no intermediate escapes the type.
- **other**: Alternating signs are handled by keeping separate positive and negative fixed-point accumulators and subtracting once at the end after a comparison guard, so borrows never go negative.
- **index**: All limb loops run over the array's own range with a fixed digit capacity including guard digits, and digit-to-text output indexes a fixed 100-digit buffer with for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, characters, string building, for loops, procedures, functions and big numbers.

## External effects

- **console output** (allowed): Prints four labelled lines of 100-digit decimal values with Put_Line.

Assessed on 2026-10-15 against page revision 413640 of the [task](https://rosettacode.org/wiki/Ap%C3%A9ry's_constant) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
