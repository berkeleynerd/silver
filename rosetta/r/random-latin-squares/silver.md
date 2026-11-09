# Random Latin squares

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size array indexing and small-range integer arithmetic guarded by types, so the proofs should discharge; the remaining care is in the LCG arithmetic and in the shuffle-based construction, which avoids unbounded retry loops.

Position 691 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a fixed 5x5 array of a 0..4 subtype, start from the cyclic square L(i,j) = (i+j) mod 5, then apply Fisher-Yates shuffles driven by a deterministic LCG to permute rows, columns and symbols, which keeps the Latin property while giving every square non-zero probability of being reached from some start via a few extra random choices. A Print procedure writes each row using 'Image of each cell into a bounded String buffer, and the main procedure generates and prints two squares with different seeds. All loops are for loops over array ranges, with bounded mod-reduced random indexes. About 70 lines.

## Proof obligations to watch

- **index**: All array indexes use subtypes 0..4 (or a fixed-capacity bound) and loop variables over the arrays' own ranges, and the PRNG output is reduced with mod into the index subtype so the index check follows from the type.
- **overflow**: The linear congruential generator keeps its state in a modular or range-limited type with a modulus small enough that the multiply cannot overflow, with the product computed in a wider type before reduction.
- **termination**: A retry loop (restart a row until it avoids column conflicts) lives in a procedure, which gets no termination check; to also keep the program honestly total, use a deterministic row-by-row backtrack-free construction (random permutation of symbols followed by random row and column permutations of a cyclic square) so every loop is a bounded for loop.
- **other**: Showing every square is a Latin square needs no assertion; correctness follows from the construction, and a Fisher-Yates shuffle's swap indexes are bounded by the loop variable and a mod into the subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints two 5x5 squares line by line to standard output.

Assessed on 2026-10-15 against page revision 413875 of the [task](https://rosettacode.org/wiki/Random_Latin_squares) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
