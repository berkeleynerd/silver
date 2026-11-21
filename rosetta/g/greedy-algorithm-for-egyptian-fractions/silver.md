# Greedy algorithm for Egyptian fractions

**Candidate: proofs plausibly discharge automatically.** Denominators such as 1/1527612795642093418846225 and the 150-digit results exceed 64 bits, so the program needs fixed-capacity bignum arithmetic with long division and gcd; no annotation is strictly required if loops sit in procedures and each digit and index is guarded, but loop-carried bignum arithmetic makes discharge depend on careful program shape.

Position 1404 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent fractions as fixed-capacity decimal digit-array bignums (about 320 digits) in a record with a bounded length, with procedures for compare, subtract, multiply, ceiling-divide, mod and gcd; the greedy expansion is a while loop in a procedure that stores terms in a bounded table, with the integer part split off first and printed in square brackets. The 2-digit search is nested for loops over all a/b with a<b<=99 that skip non-reduced fractions, tracking the maximum term count and maximum denominator digit length, and printing via string building in a bounded line buffer. About 420 lines.

## Proof obligations to watch

- **overflow**: The 5/121 term 1/1527612795642093418846225 and the 150-digit denominators exceed 64 bits, so fixed-capacity digit-array bignums (about 320 digits to hold the y*ceil(y/x) product) must carry add, multiply, compare and subtract through loops, with each carry and digit range check discharged from the digit type bounds.
- **index**: Long division and gcd over digit arrays use loop-carried lengths and positions, so each index must be guarded or taken from a for-loop over the array's own range.
- **division**: The ceiling division y/x and the mod by x are guarded by an explicit x > 0 test, and the digit-level division by a bignum divisor needs a guarded nonzero check.
- **termination**: The greedy loop and the gcd loop must be while loops inside procedures, so no termination check applies, and the term count is capped by a fixed table size with an explicit visible failure outcome if reached.
- **range**: Capacity limits on digit count and term count are explicit resource limits, and an overflowing result must be reported as a specified rejection, not silently truncated.
- **other**: Bignum long division and gcd are the hardest nonlinear steps for provers without invariants, which is why the outlook is plausible rather than likely; the three-digit extra credit (2847-digit denominators) is optional and omitted.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, functions and big numbers.

## External effects

- **console output** (allowed): Prints the expansions of 43/48, 5/121 and 2014/59 and the largest-terms and largest-denominator results for the 1 to 2 digit search.

Assessed on 2026-10-15 against page revision 412015 of the [task](https://rosettacode.org/wiki/Greedy_algorithm_for_Egyptian_fractions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
