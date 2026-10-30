# Sort three variables

**Candidate: proofs likely to discharge automatically.** The program has no loops, no arithmetic and no loop-carried values, and every slice bound comes from a length whose declared subtype matches the buffer, so all checks discharge from types alone.

Position 1470 in the [progression](../../progression.md#stage-28), in stage 28.

## Approach

The three text values live in fixed 25-character String buffers, each paired with a length of subtype 0 .. 25, and the three numbers are Integer variables holding the task's example data. Two swap procedures with in out parameters (one for buffer and length pairs, one for integers) are applied in a three-step compare-and-swap network using String "<" on slices and Integer "<". Results are printed with Put_Line on the slices and on Integer'Image. About 55 lines.

## Proof obligations to watch

- **index**: Each slice X (1 .. X_Len) used in comparisons and output is in bounds because the length variable has a declared subtype 0 .. 25 matching the fixed 25-character buffer.

## Language surface recorded by this assessment

Integers, ranged subtypes, procedures, string indexing, string ordering and 'Image of scalars.

## External effects

- **console output** (allowed): The sorted strings and integers are printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413920 of the [task](https://rosettacode.org/wiki/Sort_three_variables) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
