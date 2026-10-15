# String interpolation (included)

**Candidate: proofs likely to discharge automatically.** The program needs only a String constant, bounded concatenation of static-length operands and Put_Line, all of which today's Silver supports, so every check is static and discharges trivially.

Position 10 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A String constant holds "little" and Main prints "Mary had a " & Little & " lamb." with Silver_IO.Put_Line, using Ada's built-in concatenation as the language's interpolation mechanism. There is no input, no loop and no guard, and the concatenation length is static. About 8 lines.

## External effects

- **console output** (allowed): The interpolated sentence is printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413061 of the [task](https://rosettacode.org/wiki/String_interpolation_%28included%29) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
