# Diversity prediction theorem

**Candidate: proofs plausibly discharge automatically.** Small integer arrays, exact rational arithmetic and for loops with bounded ranges let every check follow from types and guards, but accumulator guards and decimal formatting need careful shape, so plausible rather than likely.

Position 412 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Embed the two examples as constant integer arrays (estimates in a ranged subtype like -1000..1000) and run a procedure over each that computes exact rational quantities with integers: sum of squared errors over n for average error, (n*truth - sum) squared over n squared for crowd error, and their difference for diversity. Use for loops with guarded 64-bit accumulators, then render each value as a fixed five-decimal text in a bounded buffer by integer division and mod, printing with Put_Line. This avoids floating point entirely while matching the required values (3.00000, 0.11111, 2.88889 and 14.50000, 4.00000, 10.50000). About 110 lines.

## Proof obligations to watch

- **overflow**: Sums and sums of squares are loop-carried accumulators that GNATprove knows only by type, so the program uses a 64-bit accumulator with estimates in a small ranged subtype and a guard before each addition that routes to a visible rejection outcome.
- **division**: Division by the estimate count and by its square is discharged because the count is a constant of at least 1 and the decimal scaling factor is a literal.
- **range**: Computing five decimal digits with integer scaling (value times 100000 divided by n squared) multiplies bounded squares, which needs the operand ranges kept small enough that the product fits in 64 bits.
- **length**: Formatted output strings are built in fixed-size bounded buffers whose capacity must be shown sufficient for the maximum digit count.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The true value, estimates and the three computed errors are printed to standard output.

Assessed on 2026-10-15 against page revision 415405 of the [task](https://rosettacode.org/wiki/Diversity_prediction_theorem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
