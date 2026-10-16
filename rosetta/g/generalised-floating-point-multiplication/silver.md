# Generalised floating point multiplication

**Candidate: proofs plausibly discharge automatically.** No Oracle rule is broken: this is bounded-digit-array big-number arithmetic with for loops and guarded carries, but the generic base parameter, floating-point conversion and nested carry loops make discharge depend on careful program shape.

Position 1530 in the [progression](../../progression.md#stage-32), in stage 32.

## Approach

Represent a balanced-base real as a record holding a fixed-capacity array of digits (a ranged subtype -1..1 for ternary, wider for base-27) plus a fixed fractional scale, inside a generic package parameterised by base and capacity, with a bounded Digits_Used/overflow flag. Add, negate and multiply are for-loop procedures over the digit arrays with a carry held in a small ranged subtype and explicit guards on i+j index sums and capacity overflow, rejecting or flagging results that do not fit. Text conversion builds bounded String buffers using '+', '-', '0'; the native real is converted by a guarded floating-point loop that extracts 81 fractional digits, and both test cases print to console with embedded data. About 380 lines.

## Proof obligations to watch

- **overflow**: Digit-wise addition and multiplication carries stay within a ranged carry subtype and each partial product is bounded by the digit subtype, so checks follow from types, but the shifted accumulation needs guards on every loop-carried sum.
- **index**: Product index i+j and the fractional scale offsets are guarded against the fixed capacity before each array access, with an overflow flag as the visible outcome.
- **floating point**: Converting -436.436 to trits needs the real guarded to a bounded range before truncation and repeated multiplication by the base, which provers handle only with explicit range guards.
- **range**: Conversion to native integer reports overflow by comparing against the Integer range before accumulating, and base-27 digit values must stay within the declared digit subtype.
- **termination**: All loops are for loops or while loops inside procedures, so no variant is needed and recursion is avoided.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, floating point, floating-point images, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, generics, packages, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Test case 1 values and the 27 by 12 multiplication table are written as text.

Assessed on 2026-10-15 against page revision 399693 of the [task](https://rosettacode.org/wiki/Generalised_floating_point_multiplication) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
