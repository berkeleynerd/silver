# Naming conventions

**Candidate: proofs likely to discharge automatically.** The program is a fixed list of Put_Line calls on string literals, which today's Silver already supports. Its only proof obligations are initialization and data flow, which are trivial for this program.

Position 57 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The task asks for documentation, not computation, so the program is a parameterless Main procedure that calls Silver_IO.Put_Line on fixed String literals. Those lines describe Ada/Silver naming conventions with short examples: lowercase reserved words, Capital_Snake_Case identifiers, full words, matching end labels and lowercase package file names. The program reads no input and has no loops or arithmetic, so it needs no guards. About 40 lines.

## External effects

- **console output** (allowed): The program prints its description of the naming conventions and their examples as lines of text.

Assessed on 2026-10-15 against page revision 415447 of the [task](https://rosettacode.org/wiki/Naming_conventions) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
