# Resistance network calculator

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over constrained arrays in procedures with no recursion, but floating-point elimination with loop-carried matrix values needs per-assignment range guards and pivot guards, so discharge depends on careful program shape rather than being routine.

Position 1142 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the four example network strings as fixed-length String constants, with a procedure that scans each '|'-separated record with a bounded while loop, parses three validated integers (start node, end node, resistance) and stamps conductances into a constrained 2-D Float matrix of at most 16 nodes. A second procedure solves the nodal system with partial-pivot Gaussian elimination using for loops and pivot-magnitude guards, rejecting singular or out-of-range values, then prints the result rounded to five decimals via integer scaling and 'Image. About 230 lines.

## Proof obligations to watch

- **floating point**: Gaussian elimination on a 16x17 Float matrix leaves every loop-carried entry at its type range, so each stored value must be a bounded Float subtype guarded (reject if magnitude exceeds a documented limit) before assignment, and float provers handle this slowly.
- **division**: The pivot divisor is checked for a magnitude above a small epsilon before dividing, with a singular or disconnected network rejected visibly as an invalid input.
- **overflow**: Conductance 1/r, the products t*m(i,l) and the final scaling to an integer for printing each need operand range guards so results stay inside the bounded subtype.
- **index**: Node numbers parsed from the string are validated against the node count and string positions are guarded against the string length before every read.
- **range**: Parsed integers accumulate digit by digit in a loop and need a guard on the running value against a documented maximum before each multiply-add.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, floating point, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints each network's computed equivalent resistance as a line of text.

Assessed on 2026-10-15 against page revision 390392 of the [task](https://rosettacode.org/wiki/Resistance_network_calculator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
