# Trabb Pardo–Knuth algorithm

**Candidate: proofs plausibly discharge automatically.** The control flow is simple for loops and every check follows from ranged types and guards, but it depends on admitted floating-point parsing, Sqrt and formatting operations with verified contracts, so discharge hinges on careful range guards.

Position 1224 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Store eleven values in a Float array with a bounded range subtype, read each through an admitted parse operation that rejects invalid or out-of-range text with a visible message, then loop in reverse printing each item and either its f(x) result or a too-large alert. The function is guarded so that when x is above a small bound the alert is printed without computing the cube, otherwise f is computed within safe bounds and compared with 400.0. About 55 lines.

## Proof obligations to watch

- **floating point**: x**3 and the sum cannot overflow because inputs are validated into a documented range such as -1000.0 .. 1000.0 and values above 5.0 in magnitude are decided by comparison before computing.
- **range**: Sqrt of abs(x) needs a nonnegative argument and a bounded result, which follows from the ranged float type and the verified library contract.
- **index**: The eleven-element array is filled and read back with for loops over its own range, so indexes are routine.
- **other**: Parsing decimal text into floats and formatting results depends on an admitted library with specified failure outcomes; unparsable or out-of-range input must be rejected visibly, not clamped.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, arrays, for loops, procedures, functions, text parsing, floating-point images, standard input, Put without a newline, Boolean objects and string building.

## External effects

- **console output** (allowed): Prints the prompt and one result or alert line per item.
- **standard input** (allowed): Reads eleven textual numeric inputs from standard input.

Assessed on 2026-10-15 against page revision 414553 of the [task](https://rosettacode.org/wiki/Trabb_Pardo%E2%80%93Knuth_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
