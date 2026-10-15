# Safe mode

**Candidate: proofs likely to discharge automatically.** The program only prints fixed string literals with Put_Line, which today's Silver already supports, so its only proof obligations are trivial initialization and data-flow checks.

Position 20 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The task asks for a descriptive answer, so the program is a parameterless Main with pragma SPARK_Mode (On) that prints a sequence of string literals with Silver_IO.Put_Line. The output states "Yes" and lists what Silver always restricts: no exception handlers, goto, pointers or aliasing, no unchecked conversion or foreign calls, no contracts or pragmas from authors, and effects only through admitted library operations. It has no input, branching or computation, so it needs no guards. About 20 lines.

## External effects

- **console output** (allowed): The program prints the yes answer and the list of features Silver restricts, one Put_Line per line.

Assessed on 2026-10-15 against page revision 391207 of the [task](https://rosettacode.org/wiki/Safe_mode) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
