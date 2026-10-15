# Ethiopian multiplication

**Candidate: proofs plausibly discharge automatically.** Every operation is plain integer arithmetic on declared ranges, and the only non-routine checks are the loop-carried doubling and sum, which an explicit rejecting guard against a documented limit makes dischargeable without annotations.

Position 370 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Define a bounded subtype of Long_Long_Integer for operands, small functions Halve, Double and Is_Even, and a Multiply procedure that loops while the left value exceeds zero, adding the right value to a sum when the left is odd, then halving left and doubling right under a guard that rejects when the limit would be exceeded. Main embeds 17 and 34, calls Multiply, and prints the result via Image and Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The doubled right column and the running sum are loop-carried values, so the program uses a wide ranged type and an explicit visible guard that rejects operands whose doubling or sum would exceed the declared limit.
- **termination**: Halving is done in a procedure with a while loop (or a for loop with a fixed 31-step bound inside the function), so no variant is needed.
- **range**: Halve and double are functions on subtypes where 2*n and n/2 stay in range by declaration, with the doubling guard supplying the upper bound.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, functions, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the product 578 (and optionally the table rows) with Put_Line.

Assessed on 2026-10-15 against page revision 415417 of the [task](https://rosettacode.org/wiki/Ethiopian_multiplication) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
