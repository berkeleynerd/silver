# Death Star

**Candidate: proofs plausibly discharge automatically.** The task is satisfied by text art, so there is no graphics or float requirement, and integer math over small ranged subtypes means every overflow, index and range check follows from types and guards without any loop invariant. The main risk is just the amount of loop-nested nonlinear integer arithmetic and per-row string building, which depends on careful program shape.

Position 816 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The picture is rendered as text art on a fixed integer grid of about 60 columns by 40 rows, with the big sphere centered at the origin and the subtracting sphere offset, using integer-only geometry. For each cell, a for loop over depth z finds the nearest point that is inside the big sphere and not inside the small sphere; a hit on the small sphere's inner surface uses its inward normal, otherwise the big sphere's outward normal. The shade is an integer dot product with a fixed light vector, clamped by guards into an index of a constant character ramp, and each row is built in a fixed-length String and printed with Put_Line. About 80 lines.

## Proof obligations to watch

- **overflow**: The squared-distance and light dot-product terms are nonlinear, but coordinates are ranged subtypes of about +-130 so every product and sum fits comfortably in Integer and the provers only need the type bounds.
- **index**: The shade-ramp index is clamped with explicit if guards just before indexing a constant String, so the check follows from the guard rather than from any loop invariant.
- **range**: The row buffer is a fixed-length String indexed by the for-loop variable offset by a constant, so the offset index stays in range by subtype bounds on the loop variables.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, string indexing, for loops, case statements, procedures, functions, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): The shaded death star is rendered as lines of text art written to standard output.

Assessed on 2026-10-15 against page revision 414934 of the [task](https://rosettacode.org/wiki/Death_Star) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
