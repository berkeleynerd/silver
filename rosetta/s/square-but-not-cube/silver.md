# Square but not cube

**Candidate: proofs likely to discharge automatically.** All arithmetic sits in small constant for-loop ranges and the only loop-carried counter is guarded before its increment, so every check follows from types and guards. No while loops, functions or recursion are involved, so there are no termination obligations.

Position 84 in the [progression](../../progression.md#stage-6), in stage 6, which adds Boolean objects.

## Approach

Main runs a for loop of N over 1 .. 40, computes Sq := N*N, and uses an inner for loop of I over 1 .. 13 to set a Boolean flag when I*I*I = Sq. If the square is not a cube and Count < 30, it increments Count and prints the number with Integer'Image through Put; a final empty Put_Line ends the line. Everything is bounded by constant ranges, so no loop invariant is needed, and the optional square-and-cube part is omitted. About 25 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Count is incremented only under an explicit Count < 30 guard, and N*N and I*I*I are bounded by the for-loop ranges (N up to 40, I up to 13), so no overflow check can fail.

## Language surface beyond today's Silver

Integers, Boolean objects, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 30 qualifying squares on one line.

Assessed on 2026-10-15 against page revision 415318 of the [task](https://rosettacode.org/wiki/Square_but_not_cube) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
