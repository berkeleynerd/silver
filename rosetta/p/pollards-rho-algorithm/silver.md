# Pollard's rho algorithm

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by a ranged subtype so overflow checks follow from types, and all unbounded loops sit in procedures, but the loop-carried x, y and mulmod values need careful range shaping to avoid annotations. The 70-bit example is optional and omitted since it needs big numbers.

Position 1517 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

Embed the 32, 34 and 55-bit example numbers (plus a prime) in a constant array; a procedure Mul_Mod does shift-and-add modular multiplication on a capped ranged subtype, a procedure GCD is iterative Euclid, and a Rho procedure runs Floyd cycle detection in a bounded for loop with a fixed constant and start value, reporting a factor or failure. Main loops over the array with a for loop, rejects any n outside 2..2**61, and prints results through Silver_IO.Put_Line using 'Image. About 90 lines.

## Proof obligations to watch

- **overflow**: x*x+c exceeds 64 bits for the 55-bit example, so a procedure mulmod uses double-and-add with operands in a subtype capped at 2**61 so every sum stays below 2**63.
- **range**: Results of mod n must be known to lie in the capped subtype, which holds because n is guarded to 2..2**61 before the call and mod results are bounded by the divisor.
- **termination**: Euclid GCD and the mulmod halving loops are while loops, so they live in procedures (no termination check), and the rho loop is a for loop with a fixed iteration cap that yields a visible failure outcome.
- **division**: mod n and the GCD remainder need nonzero divisors, discharged by guarding n >= 2 and testing the GCD divisor against zero before the mod.

## Language surface recorded by this assessment

Integers, integer division, exponentiation, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints each test number with the factor found or a failure message.

Assessed on 2026-10-15 against page revision 406383 of the [task](https://rosettacode.org/wiki/Pollard's_rho_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
