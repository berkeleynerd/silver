# Create a two-dimensional array at runtime

**Candidate: proofs likely to discharge automatically.** Every check comes from the Dimension subtype, the array's own bounds, a static digit test, or an overflow guard placed just before the accumulator update, so no annotation is needed. The runtime-sized stack array stays within a fixed, documented size limit.

Position 1535 in the [progression](../../progression.md#stage-32), in stage 32.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Main reads two arguments and calls a Parse_Dimension procedure on each. The procedure checks every character for a digit with a for loop over the string's range, guards its accumulator against overflow, and returns a Valid flag with a value in subtype Dimension (1 .. 100); any invalid or out-of-range text is rejected with a message. A declare block then declares Matrix : Matrix_Type (1 .. Rows, 1 .. Cols) := (others => (others => 0)) from an unconstrained two-dimensional Integer array type, assigns Matrix (Rows, Cols), and prints it with 'Image; the block's exit releases the array. About 55 lines.

## Proof obligations to watch

- **overflow**: The digit-parsing accumulator is guarded before each step (Value > (Max_Dim - Digit) / 10 rejects), so its range check follows from the guard placed just before the update.
- **initialization**: Writing one element does not make the whole matrix initialized for flow analysis, so the declaration takes an (others => (others => 0)) aggregate before the element is written and read.
- **stack**: The matrix lives on the stack with a size that depends on input, but a documented subtype Dimension is range 1 .. 100 caps it at a fixed size, which fits the sufficient-memory premise.
- **index**: Indexing Matrix (Rows, Cols) is safe because Rows and Cols are the upper bounds of the block-declared array, and both have subtype Dimension.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, text parsing, for loops, procedures, multidimensional arrays, unconstrained arrays, block statements, 'Image of scalars and further arguments.

## External effects

- **arguments** (allowed): The two dimensions are taken from the first and second command-line arguments.
- **console output** (allowed): The written element is printed, and invalid input gets a rejection message.
- **exit status** (allowed): Invalid or out-of-range dimensions are rejected through Silver_Arguments.Reject, which sets a failure status.

Assessed on 2026-10-15 against page revision 415369 of the [task](https://rosettacode.org/wiki/Create_a_two-dimensional_array_at_runtime) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
