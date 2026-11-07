# Inventory sequence

**Candidate: proofs plausibly discharge automatically.** Every check is an array index or counter increment that a guard immediately before it can discharge, and the loops live in a procedure so no variant is needed. It is plausible rather than likely because the index and counter values are loop-carried and the position of the first element at or above 10,000 may be large, requiring a wide integer type and a visible limit outcome.

Position 259 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Only the occurrence counts are needed to generate the sequence, so the program keeps a constrained array Counts indexed by value (0..10_000) plus a 100-element array holding the first elements for display. A while loop in Main restarts the inventory at i = 0, reads j = Counts(i), increments Counts(j), advances the position, records the element if among the first 100, and checks the 1000..10000 thresholds, with explicit guards on i, j and the counters before each indexing or increment. After the loop it prints the 100 elements as text rows and each threshold's position and value; the optional plot is omitted. About 90 lines.

## Proof obligations to watch

- **index**: Counts is indexed by the loop-carried inventory index i and by each element value j, so each use is preceded by an explicit guard against the array bound, with an overflow-limit outcome reported visibly rather than clamped.
- **overflow**: The per-value count increment and the running position are loop-carried, so each is guarded just before the +1 and the position is held in a wide enough integer type, with a visible stop message if a limit were hit.
- **termination**: The main loops are while loops inside the Main procedure, which gets no termination check, and the sequence is known to keep growing so reaching the 10,000 threshold is not proof-relevant.
- **range**: The line-formatting buffer for the first-100 display uses fixed-width text built from image conversions, so lengths must be bounded by the integer subtype ranges.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the first 100 elements and the position and value of each threshold hit as text lines.

Assessed on 2026-10-15 against page revision 412852 of the [task](https://rosettacode.org/wiki/Inventory_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
