# Enforced immutability

**Candidate: proofs likely to discharge automatically.** The task is satisfied by Ada's constant declarations, which are compile-time enforced, and the program has only static values and output calls, so every check is trivial. The only surface beyond today's Silver is an integer constant and its 'Image.

Position 40 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Main declares a String constant and an Integer constant with the constant keyword, so the compiler rejects any later assignment to them, and a comment notes the illegal assignment that would not compile. It prints both values with Put_Line, using 'Image for the integer, in straight-line code with no loops or guards. About 15 lines.

## Language surface beyond today's Silver

Integers and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the values of its constants with Silver_IO.Put_Line to show they were created and remain unchanged.

Assessed on 2026-10-15 against page revision 414182 of the [task](https://rosettacode.org/wiki/Enforced_immutability) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
