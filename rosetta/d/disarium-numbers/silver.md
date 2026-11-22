# Disarium numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded: a fixed 10-digit limit, a literal power table and for loops give routine index and range checks, with only the subtraction-based accumulator guard requiring careful shape. No annotations or recursion are needed, so proofs should discharge with some care.

Position 681 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program searches N upward in a bounded range (0 to 2_700_000, covering all 19 numbers that brute force can reach, with the first 18 required) using a for loop in Main, and a Boolean function Is_Disarium that extracts the digit count with a for loop over 1..10 and then peels digits with a second for loop. Digit powers come from a constant 10x10 table of literals, and the function subtracts each term from a remaining value so no accumulator can overflow, returning False once remaining goes negative. Each hit is printed with Put_Line of the integer image, and the stretch 20th number (above 2^63) is left out as optional since brute force cannot reach it. About 45 lines.

## Proof obligations to watch

- **overflow**: The power sum is a loop-carried accumulator, so the program instead subtracts each term from a remaining value bounded by N and returns False as soon as it goes negative, which keeps every operation inside the type range.
- **index**: The power table is indexed by a digit 0..9 (from mod 10) and a position 1..10 in declared subtypes, so the index checks follow from types as long as the position counter is clamped by the digit-count for loop.
- **termination**: The digit-counting and digit-summing loops are for loops over 1..10 so the function needs no variant, and the outer search is a for loop in a procedure.
- **range**: Position is derived from a decrementing counter, so the program uses for loops with reverse ranges over 1..Length rather than a while loop with a subtracted counter to keep the subtype range check provable.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints each Disarium number found, one per line.

Assessed on 2026-10-15 against page revision 415196 of the [task](https://rosettacode.org/wiki/Disarium_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
