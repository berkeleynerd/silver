# Equilibrium index

**Candidate: proofs plausibly discharge automatically.** The algorithm is two for loops over an array's own range, so indexes and termination are routine, but the loop-carried sums need guards because no invariant can be written, which makes discharge depend on careful shape. Nothing needs an annotation, recursion or heap, so the outlook is plausible.

Position 993 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the example sequence (and a few more) as constrained arrays of a ranged element subtype, with a Boolean result array over the same index range. A procedure does a first for loop to total the elements into a 64-bit right sum, then a second for loop that subtracts each element, marks the index when left and right sums are equal, then adds the element to the left sum, with a guard before each accumulation that rejects out-of-bound sums. A final for loop prints each marked index with its image, and a line for the empty case. About 70 lines.

## Proof obligations to watch

- **overflow**: The running left and right sums are loop-carried and GNATprove knows only their type range after the first iteration, so the program uses a 64-bit sum type with elements restricted to a small subtype and rejects the input visibly when a sum leaves a guarded bound before each addition or subtraction.
- **range**: Element values are a declared subtype, and the fixed maximum length (say 1000) times the element bound keeps true sums far inside the sum type, but the prover sees this only through the per-step guard rather than an invariant.
- **index**: All array accesses are for-loop indexes over the array's own range, and the result array is indexed by the same range, so these are routine.
- **other**: The task's 'very long' sequence is met only by a documented fixed capacity, which Oracle rule 7 allows, with over-capacity input given a specified rejection outcome.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars, Put without a newline, string building, unconstrained arrays, functions and integer division.

## External effects

- **console output** (allowed): Prints the sequences and their equilibrium indices to standard output.

Assessed on 2026-10-15 against page revision 413442 of the [task](https://rosettacode.org/wiki/Equilibrium_index) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
