# Sort stability

**Candidate: proofs likely to discharge automatically.** The task only asks for a documented report of whether a built-in sort exists and is stable, which is fixed text output with no arithmetic, loops or input, so every check is trivially discharged by what Silver already supports.

Position 9 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The program is a parameterless Main with SPARK_Mode On that emits a few Put_Line calls with literal text stating that Ada 2022 supplies built-in array sorts (Generic_Array_Sort and Generic_Constrained_Array_Sort) that are not guaranteed stable, and that the Doubly_Linked_Lists container sort is stable. There is no data, no loop and no input, so no guards are needed. About 8 lines.

## External effects

- **console output** (allowed): The program prints the findings about the built-in sort routines with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414488 of the [task](https://rosettacode.org/wiki/Sort_stability) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
