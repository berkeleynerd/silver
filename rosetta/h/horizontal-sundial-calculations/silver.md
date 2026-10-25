# Horizontal sundial calculations

**Candidate: proofs plausibly discharge automatically.** No contracts or recursion are needed and every loop is a bounded for loop in a procedure, but floating-point trigonometry with no prover-visible bounds on Tan and hand-written decimal parsing make discharge depend on careful range guards.

Position 1233 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

A procedure reads three lines from stdin, parses each into a Float with validation and range limits (latitude within -90..90, longitude and meridian within -180..180), and rejects invalid input with a message. It computes the sine of latitude once, then a for loop over H in -6..6 computes the hour angle and the dial line angle, guarding the Tan result by magnitude before multiplying, and prints each line as bounded text. About 110 lines.

## Proof obligations to watch

- **floating point**: Sin, Tan and Arctan come from an admitted elementary-function library, and Tan has no bound the prover can use, so the program must test the Tan result against a fixed magnitude and print a visible 'vertical line' outcome otherwise.
- **overflow**: Hour angle 15*H - (Lon - Meridian) and the degree-to-radian scaling stay bounded only because parsed latitude, longitude and meridian are validated to -180..180 (latitude -90..90) and invalid input is rejected.
- **range**: Parsing decimal text into Float with validation (sign, digits, one point, length limit) needs loop-carried accumulators kept in range by guards or by a bounded digit count.
- **length**: Float'Image output must fit a fixed-size buffer when building each report line.

## Language surface recorded by this assessment

Floating point, floating-point images, text parsing, standard input, Put without a newline, for loops, ranged subtypes, procedures, 'Image of scalars, string building, Boolean objects and conditional expressions.

## External effects

- **standard input** (allowed): The operator enters latitude, longitude and legal meridian, read as lines of text from standard input.
- **console output** (allowed): Prompts, the sine of latitude, the longitude difference and the 13 hour lines are printed.

Assessed on 2026-10-15 against page revision 415522 of the [task](https://rosettacode.org/wiki/Horizontal_sundial_calculations) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
