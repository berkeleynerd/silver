# Sum of squares

**Candidate: proofs likely to discharge automatically.** Named component bounds make both indexed and foreach squares safe. A fixed-capacity vector with Count = 0 handles the required empty case, and executable guards establish accumulator containment. The driver uses only the narrow named Integer subtype and existing array/loop fragment.

Position 51 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main declares a constant six-element array of an Integer subtype 0..9, initialized to 3,1,4,1,5,9, plus a Count in 0..6. Count = 0 represents an empty vector; an index loop over 1..Count executes zero times and prints 0. After resetting Sum, a foreach loop squares each actual component and accumulates it under an explicit range guard, printing 133. No helper procedure, null array or subtype conversion is needed. About 29 lines.

## Proof obligations to watch

- **overflow**: Component subtype 0..9 bounds each square by 81. Before adding it, the program checks Sum <= 2147483566, with a visible overflow message in the alternative arm.

## Language surface recorded by this assessment

Bounded mutable Integer objects, fixed-size Integer arrays, constant Integer-array iteration, Integer image, scalar guard refinement, named Integer subtypes and bounded components and Integer range for loops.

## External effects

- **console output** (allowed): Prints the sum of squares for an empty vector and for an embedded sample vector.

Initially assessed on 2026-10-15 against page revision 415389 of the [task](https://rosettacode.org/wiki/Sum_of_squares) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-29 by Codex through targeted source review; see the [review record](../../assessment-named-integer-subtypes-20261029.md).
