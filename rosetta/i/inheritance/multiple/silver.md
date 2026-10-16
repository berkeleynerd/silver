# Inheritance/Multiple

**Candidate: proofs likely to discharge automatically.** The task is satisfied by type declarations alone (a tagged type, an interface and a type extension of both), and SPARK supports these. No run-time checks arise, so Bronze and Silver proof is trivial once Silver admits tagged and interface types.

Position 1556 in the [progression](../../../progression.md#stage-34), in stage 34.

## Approach

Main declares Camera as a tagged null record, Mobile_Phone as an interface, and Camera_Phone as a type that derives from Camera and Mobile_Phone with a null record extension. The task needs no operations, so the program has no data and no control flow, and it prints one confirmation line with Silver_IO.Put_Line. About 12 lines.

## Language surface recorded by this assessment

Tagged types.

## External effects

- **console output** (allowed): The Main procedure prints one confirmation line with Silver_IO.Put_Line so the program has a visible outcome.

Assessed on 2026-10-15 against page revision 412847 of the [task](https://rosettacode.org/wiki/Inheritance/Multiple) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
