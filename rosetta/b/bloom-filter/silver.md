# Bloom filter

**Candidate: proofs likely to discharge automatically.** Every operation is a bounded for loop over ranged integers with mod reduction, so all checks follow from types and static bounds with no unbounded loop-carried value, and no annotation is needed. The memory comparison is computed arithmetic on declared sizes, which avoids files, floats and system memory queries.

Position 1069 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

The filter is a fixed-capacity array of 8192 Boolean bits with a deterministic polynomial hash over the characters of each embedded dictionary word, split into two ranged hashes and combined by double hashing for K=4 probes via a for loop. Add is a procedure and Contains a function over a String parameter indexed by its own 'Range, and Main adds an embedded word list, tests one present and one absent word, then prints the filter size in bytes against the hash-set size (count times 4 bytes plus table overhead) using Integer'Image. About 110 lines.

## Proof obligations to watch

- **overflow**: The hash step h*31+c is computed on a hash subtype bounded below 2**20 and a Character position of at most 255, so the product fits in Integer and is reduced with mod before storing.
- **index**: Each bit index is the result of mod by the fixed bit count, so it is statically within the bit array's range.
- **range**: The k-th probe index (h1 + k*h2) mod M uses h1 and h2 bounded below 2**20 and k at most 7, so the sum stays in range before the mod.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, for loops, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints membership results for sample words and the byte sizes of the filter versus a hash set.

Assessed on 2026-10-15 against page revision 415137 of the [task](https://rosettacode.org/wiki/Bloom_filter) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
