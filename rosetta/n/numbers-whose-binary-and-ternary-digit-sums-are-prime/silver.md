# Numbers whose binary and ternary digit sums are prime

**Candidate: proofs likely to discharge automatically.** All values are small and bounded by declared ranges (n below 200, sums at most 10), and every loop is a for loop with a static bound, so the checks follow from types and one accumulator guard. No annotation is needed.

Position 326 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

A function Digit_Sum (N, Base) loops a fixed number of times, adding N mod Base to a ranged accumulator and dividing N by Base, and a function Is_Prime tests divisors 2 to 9 on sums of at most 10 with a for loop. The Main loop runs n from 1 to 199 with a ranged subtype and prints each qualifying n with Put_Line of its image, because a line-terminator-free Put may be unavailable. About 45 lines.

## Proof obligations to watch

- **overflow**: The digit-sum accumulator is loop-carried so GNATprove knows only its type, which is handled by declaring it as a wide ranged subtype and guarding the addition with a visible check that never changes the result, since at most 8 base-2 and 5 base-3 digits are summed.
- **termination**: Digit extraction uses for loops with fixed iteration counts (8 binary, 5 ternary digits, enough for n below 256), so the functions need no variant.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The qualifying numbers are printed to standard output.

Assessed on 2026-10-15 against page revision 406216 of the [task](https://rosettacode.org/wiki/Numbers_whose_binary_and_ternary_digit_sums_are_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
