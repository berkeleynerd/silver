# Addition-chain exponentiation

**Candidate: proofs plausibly discharge automatically.** Integer search state is bounded by types and guards, and the float matrix multiplication can be range-bounded with a visible rejection outcome, so no annotations are needed, but loop-carried float sums and the search-shape guards make discharge depend on careful program structure.

Position 1116 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Find a shortest addition chain for each exponent by iterative deepening depth-first search in a procedure with an explicit stack in fixed-size Integer arrays (maximum chain length around 24, strictly increasing elements pruned against the target by doubling bounds). Then evaluate the chain with a fixed 6x6 Long_Float matrix type (or scalar powers for the easier alternative), recording for each chain element which two earlier elements sum to it, counting multiplications, and printing the chain, count and results with embedded constants; A^(n*m) is computed as (A^n)^m by a second chain for m. About 230 lines.

## Proof obligations to watch

- **index**: The iterative-deepening search keeps its chain and position arrays in a bounded depth, with a guard before each push and each chain-element lookup, so indexes discharge from the declared bounds.
- **overflow**: Chain values are integers bounded by the target (about 850 million for 31415 times 27182, within Integer), and every sum of two entries is guarded against exceeding the target before it is stored.
- **floating point**: Matrix entries are held in a bounded Long_Float subtype and each product-sum is a single unrolled expression (or has a per-iteration range guard) so the prover can bound it; if a result leaves the bound the program prints a visible rejection rather than clamping.
- **termination**: The search uses while loops only inside procedures, which get no termination check, and the iterative-deepening limit is capped at a fixed maximum so the loops are finite.
- **other**: Exhaustive optimal-chain search for 31415 and 27182 may be slow at run time, which is a performance matter and not a proof obligation, though the fixed depth cap must be sized so the optimal lengths are reachable.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, floating point, floating-point images, 'Image of scalars, arrays, multidimensional arrays, for loops, while loops, procedures, functions, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the chains, multiplication counts, resulting matrices or powers, and optionally the A003313 terms.

Assessed on 2026-10-15 against page revision 408506 of the [task](https://rosettacode.org/wiki/Addition-chain_exponentiation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
