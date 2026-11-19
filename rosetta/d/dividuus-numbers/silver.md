# Dividuus numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded integer work whose checks follow from subtype ranges and nonzero guards, and no loop in a function needs a variant, but the loop-carried digit product and the roughly ten-million-iteration stretch search need careful typing and shape.

Position 406 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A subtype of 0..10**10 holds candidates, digit sums and products; functions digit_sum, digit_product, digital_root and mult_digital_root use for loops over ten digit positions (peeling n mod 10, n / 10) and a fixed number of reduction rounds, and Is_Dividuus guards each division against zero. The Main procedure uses a while loop bounded by found < 50 and the candidate limit for the first part, then a for loop over 990_000_000 .. 1_000_000_000 for the stretch, printing hits with Put_Line and 'Image. About 95 lines.

## Proof obligations to watch

- **overflow**: The digit-product accumulator is loop-carried, so it must be a wide integer subtype (or guarded against a cap far above 9**10) so that multiplying by a digit provably cannot overflow.
- **division**: Each mod by digit sum, digit product, digital root and multiplicative root is preceded by an explicit nonzero guard, which also gives the required result of false for numbers with a zero digit.
- **termination**: Digit extraction and the repeated digital-root reductions use for loops with fixed iteration counts (ten digits, a fixed number of reduction rounds) inside functions, avoiding while loops that would need a variant.
- **range**: The search counters in the main procedure's while loops are loop-carried and need loop conditions bounding them (found below 50, candidate below 10**9) so that increments cannot overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, procedures, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first fifty dividuus numbers and the two stretch results to standard output.

Assessed on 2026-10-15 against page revision 410180 of the [task](https://rosettacode.org/wiki/Dividuus_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
