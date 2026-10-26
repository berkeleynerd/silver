# Decimal floating point number to binary

**Candidate: proofs plausibly discharge automatically.** Every check reduces to bounded digit arrays and capacity guards placed before each write, with no recursion, heap, or float, but the many loop-carried carries and lengths need careful guarded program shape, so discharge is plausible rather than routine. The pi example forces a declared bit-count limit with an explicit truncation outcome.

Position 1138 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the three sample inputs (23.34375, 1011.11101, and a long pi string) as String constants, parse each character by character into a bounded integer-part digit array and a bounded fraction digit array, rejecting any non-digit or over-capacity input with a printed message. Decimal to binary converts the integer part by repeated division by 2 and the fraction by repeated doubling of the decimal digit array (carry per digit), emitting up to a fixed number of bits and marking visible truncation when the fraction does not terminate; binary to decimal accumulates the integer part in a bounded range and converts the fraction by repeated halving of a decimal digit array, which is exact. All output is built in fixed-length buffers with tracked lengths and printed with Put_Line. About 170 lines.

## Proof obligations to watch

- **index**: Digit buffers and output strings are fixed-capacity, and every write is preceded by a count-versus-capacity guard that stops with a visible truncation or rejection outcome.
- **overflow**: Loop-carried carries and the integer part accumulator are bounded by digit-sized subtypes and an explicit digit-count limit checked before each multiply-add, rejecting longer inputs.
- **length**: Output text is assembled into a fixed buffer with a tracked length that is guarded before each append, so slice and concatenation lengths are provable from the guard.
- **termination**: Conversion loops (repeated doubling of the fraction, repeated halving for the decimal direction) are for loops over a fixed digit capacity or while loops inside procedures, which get no termination check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, Boolean objects and case statements.

## External effects

- **console output** (allowed): Prints each embedded input beside its converted form with Put_Line.

Assessed on 2026-10-15 against page revision 415211 of the [task](https://rosettacode.org/wiki/Decimal_floating_point_number_to_binary) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
