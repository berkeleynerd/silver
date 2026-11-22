# AKS test for primes

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over bounded ranges and every value stays under a declared 2**62 bound (the largest needed is about 6.4e13), so the checks follow from types and pre-addition guards without invariants. The only non-routine part is the loop-carried Pascal row addition, which needs the explicit guard.

Position 396 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Keep a fixed-capacity array of non-negative binomial coefficients (indexes 0 to 49) in a procedure that fills row p by in-place Pascal updates with a for loop in reverse, and derive each term's sign from (-1)^(p-k) when printing. The primality test is a function using a for loop over k from 1 to N-1 that checks C(N,k) mod N = 0 (with N below 2 handled by an explicit if), and the main procedure loops p from 0 to 7 to print expansions and N from 2 to 49 to print primes. Each addition is guarded against the coefficient bound, with rejection as the visible outcome. About 90 lines.

## Proof obligations to watch

- **overflow**: The Pascal row update adds two loop-carried array values that GNATprove knows only by type, so each addition is guarded against exceeding a declared 2**62 coefficient bound with a visible rejection, and with N at most 49 the true values (below 6.4e13) never trigger it.
- **index**: Row indexes J and J-1 come from for loops over the array's own bounds (J starting at 1), so they discharge from the loop ranges.
- **division**: The mod by N occurs only inside the primality loop for N at least 2, which the preceding guard and the declared subtype range make visible.
- **length**: Output lines are written with Put pieces and image conversions of bounded integers, so fixed-size image buffers cover every value and no unbounded string is built.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the expansions of (x-1)^p for p from 0 to 7 and the list of primes under 50.

Assessed on 2026-10-15 against page revision 414044 of the [task](https://rosettacode.org/wiki/AKS_test_for_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
