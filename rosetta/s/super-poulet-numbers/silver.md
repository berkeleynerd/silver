# Super-Poulet numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared subtype bounds and fixed-bound for loops, with no recursion, but the nonlinear modular multiplication relies on the provers using those subtype ranges to bound products.

Position 916 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Declare a bounded Residue subtype of Long_Long_Integer and a Mod_Pow function using a fixed 21-iteration for loop of right-to-left square-and-multiply with the exponent halved each step. A function Is_Super_Poulet tests odd candidates by checking 2^(n-1) mod n = 1, then scans every d from 2 to n-1 with a for loop, recording whether any divisor fails 2^d mod d = 2 mod d and whether any proper divisor exists (composite). Main loops candidates 3 to 1,020,000, counts hits in a range-bounded counter, prints the first 20 and the first above 1,000,000 with its index via 'Image concatenation, with the limit sized so 1016801 (index 109) is reached. About 75 lines.

## Proof obligations to watch

- **overflow**: Modular multiplication of residues up to about 1.1 million fits in a 64-bit type only because the subtype ranges of operands and modulus bound the product, which the program declares explicitly.
- **range**: The result of 'a * b mod m' must be shown to lie inside the Residue subtype, which follows from m being a subtype bounded by the same maximum, though the provers must handle the nonlinear product.
- **division**: Modulus and trial divisor are typed with a lower bound of 1 or 2 so mod and / by them cannot divide by zero.
- **termination**: All loops are for loops with fixed bounds (21 exponent steps, trial divisors up to the candidate, candidates up to 1,020,000), so no variant is needed even inside functions.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): Prints the first 20 super-Poulet numbers and the first one above one million with its index, one per line.

Assessed on 2026-10-15 against page revision 414020 of the [task](https://rosettacode.org/wiki/Super-Poulet_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
