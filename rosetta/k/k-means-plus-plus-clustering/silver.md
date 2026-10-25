# K-means++ clustering

**Candidate: proofs plausibly discharge automatically.** Everything can be bounded integer arithmetic over fixed arrays with for loops and guards, so no annotation is needed, but 64-bit sums, loop-carried indexes and the LCG need careful typing; floating point is avoided by using integer coordinates.

Position 1431 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Points are integer-coordinate records in a fixed array of 30,000 with a cluster-index subtype, and centroids are an array of 6 integer coordinate pairs, with all random numbers from a modular LCG. K-means++ seeding does a weighted pick by cumulative squared distance in a for loop with a guard for a zero total, then Lloyd iterations run in a procedure with for loops bounded by a fixed maximum count, using integer mean division guarded by size > 0. Centroids and sizes go to the console, and a text-art grid of cluster labels and centroids is written to a file as the visualization. About 170 lines.

## Proof obligations to watch

- **overflow**: Squared distances and prefix sums over 30,000 points fit 64-bit integers because coordinates are bounded integer subtypes (for example 0..1000), giving each squared distance at most 2e6 and the total at most 6e10.
- **division**: Centroid means divide by cluster size, so each division is guarded by an explicit size > 0 test that keeps the old centroid for an empty cluster.
- **index**: Nearest-centroid and weighted-selection indexes are loop-carried, so they are kept in subtypes of the array index range, making the checks follow from types.
- **overflow**: The deterministic LCG uses a modular type, and draws are reduced with mod by a nonzero constant before conversion to a ranged subtype.
- **termination**: The Lloyd iteration is a procedure with a for loop over a fixed maximum iteration count, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, arrays, records, for loops, procedures, functions, Boolean objects, 'Image of scalars, string building, Put without a newline, file output and multidimensional arrays.

## External effects

- **console output** (allowed): Print centroids and cluster sizes.
- **files** (allowed): Write the text-art visualization of clusters and centroids to a named file.

Assessed on 2026-10-15 against page revision 414960 of the [task](https://rosettacode.org/wiki/K-means%2B%2B_clustering) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
