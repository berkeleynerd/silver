# Galton box animation

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, for-loop indexes over array ranges and capacity guards just before each bin increment, and all loops are for loops or sit in procedures so no variant is needed. The animation is plain text frames with a deterministic LCG, so no annotations or unbounded recursion arise.

Position 1127 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Fixed constants give a box with 8 pin rows and 9 bins; a procedure drops balls one at a time (a for loop over the rows), moving each ball left or right using a deterministic LCG held in a range-limited subtype, then increments the target bin only if its capacity guard passes. After each ball a procedure renders the histogram as text rows built character by character in fixed-width String buffers and prints them with Silver_IO.Put_Line along with the ball count. The ball count comes from the first argument, validated by bounded text parsing with an explicit Reject on bad input. About 110 lines.

## Proof obligations to watch

- **overflow**: Bin counters and the LCG state are loop-carried, so counters are guarded against a declared capacity with a visible 'box full' outcome and the LCG state is a range-limited subtype whose product fits in 32 bits.
- **index**: Ball positions advance by one per row inside a ranged subtype and explicit guards clamp the bin index before indexing the bin array.
- **length**: Frame lines are built in fixed-width buffers filled by for loops over the buffer's own range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Each animation frame (pins, bins and ball count) is printed as text lines to standard output.
- **arguments** (allowed): The number of balls is taken from the first command-line argument, falling back to a default when it is absent.

Assessed on 2026-10-15 against page revision 414950 of the [task](https://rosettacode.org/wiki/Galton_box_animation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
