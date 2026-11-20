# Two sum

**Candidate: proofs likely to discharge automatically.** Every check follows from declared value ranges that keep the sum of two elements within Integer, and from for-loop indexes over the array's own range, so no loop invariant is needed. The loops live in a procedure and terminate on their own, and the output uses only simple image conversion.

Position 121 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

The program declares a bounded integer subtype for values (for example -1000 .. 1000), a constrained five-element array type indexed by 0 .. 4, and embeds the example array plus a no-solution case. A procedure takes the array and the target sum and uses nested for loops, with the outer index over 0 .. 3 and the inner index over the outer index plus one .. 4, to test each pair. It records the first matching pair in a Boolean flag and two index variables, then prints "[i, j]" with Put and 'Image, or "[]" if no pair was found. About 40 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the found index pair, or an empty list, to standard output.

Assessed on 2026-10-15 against page revision 410656 of the [task](https://rosettacode.org/wiki/Two_sum) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
