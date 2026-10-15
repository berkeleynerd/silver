# Special variables

**Candidate: proofs likely to discharge automatically.** The program is a straight sequence of Put_Line calls on String literals, which today's Silver already supports, so it has no run-time checks beyond routine ones.

Position 16 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The task asks for documentation rather than computation, so a parameterless Main writes a fixed list of String literals with Silver_IO.Put_Line. The list says that Silver, like Ada, has no special variables and names the closest analogues, the language-defined attributes. There is no input, no loop and no guard. About 15 lines.

## External effects

- **console output** (allowed): The program prints the list of the language's special variables, which for Silver amounts to a statement that there are none plus the closest analogues (attributes such as 'First, 'Last, 'Length), one line each.

Assessed on 2026-10-15 against page revision 413047 of the [task](https://rosettacode.org/wiki/Special_variables) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
