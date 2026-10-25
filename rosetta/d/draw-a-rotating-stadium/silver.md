# Draw a rotating stadium

**Candidate: proofs likely to discharge automatically.** The picture is rendered as text art frames with integer-only math over small fixed ranges and for loops in procedures, so every check follows from declared types and loop bounds with no annotations needed.

Position 528 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

A constant array holds integer cosine and sine values (scaled by 1000) for a fixed number of rotation steps, and for each frame nested for loops over a small ranged-integer grid rotate each cell back by the angle using integer arithmetic. Each cell is tested against a stadium outline (a rectangle with two semicircular ends, checked by integer inequalities with a one-cell tolerance band), the result is written as a character into a fixed-length row String, and each row is printed with Put_Line, with a blank line between frames. All loops are for loops in a procedure, so no variants or invariants are needed. About 80 lines.

## Proof obligations to watch

- **overflow**: The rotated-coordinate and squared-distance arithmetic is nonlinear, but grid coordinates, the scaled sine/cosine table and the stadium dimensions are all small declared ranges, so products stay far below the Integer limits.
- **index**: Row buffer writes use the for-loop variable over the buffer's own range and frame indexes iterate the constant table's range, so index checks follow from loop bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops and procedures.

## External effects

- **console output** (allowed): Each rotation frame is printed as lines of text art, since the task needs no window.

Assessed on 2026-10-15 against page revision 414846 of the [task](https://rosettacode.org/wiki/Draw_a_rotating_stadium) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
