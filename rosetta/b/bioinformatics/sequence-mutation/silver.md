# Bioinformatics/Sequence mutation

**Candidate: proofs plausibly discharge automatically.** Everything uses bounded arrays, for loops and procedures with guards before each shift or index, so no annotation is needed, but the LCG arithmetic and length-tracking shifts need careful shape, hence plausible.

Position 1184 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

The sequence is a fixed-capacity array of a four-value Nucleotide enumeration (or Character) of capacity 256 plus a length, and a deterministic LCG with a fixed seed drives position, operation and base choices. Procedures handle generation, mutation (case on operation, with shifting for insert and delete guarded by length and capacity) and pretty printing in 60-wide rows with position prefix and per-base counts via a count array, with output through Put_Line and Put with 'Image text for numbers. Ten mutations run in a for loop and each logs its operation, position and base. About 130 lines.

## Proof obligations to watch

- **overflow**: The LCG state update is nonlinear loop-carried arithmetic, discharged by using a modular-type generator or a state range small enough that the multiply cannot overflow, with mod keeping it in range.
- **index**: Insert and delete shift elements in a fixed-capacity array with a separate length, so each shift index needs a guard against capacity and the length, and insert is rejected visibly (or capacity sized at 210) when full.
- **range**: The length counter changes by plus or minus one in a loop, so it must be kept within its subtype by guards (length greater than zero before delete, below capacity before insert) which are provable with guards just before use.
- **index**: Random position is a mod of the generator output by current length, so it needs a guard that length is nonzero to avoid division by zero and out-of-range indexing.
- **termination**: All loops are for loops or while loops inside procedures, so no termination check arises.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, enumerations, arrays, records, string building, 'Image of scalars, case statements, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the pretty-printed sequences, base counts and mutation log lines.

Assessed on 2026-10-15 against page revision 413656 of the [task](https://rosettacode.org/wiki/Bioinformatics/Sequence_mutation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
