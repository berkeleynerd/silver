# Variable declaration reset

**Candidate: proofs likely to discharge automatically.** Every check is an index in the array's own for-loop range or a plain Integer comparison, so nothing needs an invariant or annotation.

Position 61 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Embed {1,2,2,3,4,4,5} as a constant Integer array indexed 1..7, then loop with a for loop over the array's own range. Ada declares an Integer prev with an initial value of -1 in the loop's block scope; here the program declares prev before the loop, initialized to -1, and updates it each iteration, since Ada has no uninitialized-read demo. It prints each index where the element equals the preceding one using Put_Line of the integer image. About 25 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the one-based positions of repeated elements, 3 and 6.

Assessed on 2026-10-15 against page revision 414749 of the [task](https://rosettacode.org/wiki/Variable_declaration_reset) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
