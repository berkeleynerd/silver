# Polynomial synthetic division

**Candidate: proofs plausibly discharge automatically.** All array indices and divisions follow from declared lengths and guards, but the floating-point updates to loop-carried coefficients need explicit magnitude guards with a visible rejection, so discharge depends on careful program shape.

Position 1084 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Coefficients are held in fixed-capacity arrays of a bounded Float subtype with explicit lengths in a record, and a procedure performs in-place synthetic division with nested for loops. Guards check a non-zero leading divisor, divisor length not exceeding dividend length, and magnitude bounds before each store, then the four embedded examples are formatted into a bounded text buffer and printed with Put_Line. About 110 lines.

## Proof obligations to watch

- **floating point**: Each coefficient update result(i+j+1) - d*q must stay finite and in the bounded float subtype, so the loop checks operand magnitudes and the computed value against a bound before storing and rejects the division with a visible message otherwise.
- **division**: The leading divisor coefficient is tested non-zero before dividing, with a specified rejection message when it is zero.
- **index**: Indices i+j+1 stay within the dividend because loop bounds derive from the declared lengths and the divisor length is guarded to be at most the dividend length.
- **length**: Output text is built in a fixed-capacity buffer sized for the embedded examples, with a guard that rejects when appending would exceed capacity.

## Language surface recorded by this assessment

Floating point, ranged subtypes, arrays, records, procedures, for loops, floating-point images, string building, Put without a newline, integers and Boolean objects.

## External effects

- **console output** (allowed): Prints each dividend, divisor, quotient and remainder as text lines.

Assessed on 2026-10-15 against page revision 415201 of the [task](https://rosettacode.org/wiki/Polynomial_synthetic_division) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
