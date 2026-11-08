# Getting the number of decimal places

**Candidate: proofs likely to discharge automatically.** Every check follows from a for loop over the string's own range plus one explicit guard on the loop-carried position, and no loop needs an invariant or variant.

Position 491 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The two example numbers are embedded as String constants (the numeric image, as the task's examples imply), and a function Num_Places scans them with a for loop over Number'Range recording the position of the first '.' in a Natural variable. After the loop a guard checks that the position is within Number'Range before returning Number'Last - Dot, else 0, and the main procedure prints each number, padding, and the count via 'Image. About 35 lines.

## Proof obligations to watch

- **range**: The loop-carried Dot index is known only by its type after the loop, so the subtraction Number'Last - Dot is guarded by an explicit test that Dot is in Number'Range, with Dot = 0 meaning no decimal point and giving 0.
- **index**: Indexing Number inside a for loop over Number'Range is routine, and the padding length is computed from a static 10 - Length so it needs a guard or constants sized to avoid a negative length.

## Language surface recorded by this assessment

Integers, characters, string indexing, for loops, functions, 'Image of scalars, string building and Boolean objects.

## External effects

- **console output** (allowed): Prints each test number followed by its decimal-place count using Put_Line.

Assessed on 2026-10-15 against page revision 415505 of the [task](https://rosettacode.org/wiki/Getting_the_number_of_decimal_places) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
