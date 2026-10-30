# Repeat

**Candidate: proofs likely to discharge automatically.** The for loop over a Natural range terminates and has no loop-carried arithmetic, and the only call is to a procedure, so no check needs an annotation. The remaining work is Silver admitting generics with formal procedure parameters.

Position 1510 in the [progression](../../progression.md#stage-30), in stage 30, which adds generics.

## Approach

A generic procedure Repeat takes a formal parameterless procedure P and a Natural count Reps, and runs P inside a for loop over 1 .. Reps; Main instantiates it with a Hello procedure that calls Put_Line and calls it with the embedded count 3. A generic with a formal procedure expresses procedure arguments without access-to-subprogram types, and Reps is a Natural, so every call is valid. About 22 lines.

## Language surface recorded by this assessment

Generics, procedures, for loops and ranged subtypes.

## External effects

- **console output** (allowed): The repeated procedure prints a greeting line with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415274 of the [task](https://rosettacode.org/wiki/Repeat) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
