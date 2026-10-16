# Coprimes

**Candidate: proofs likely to discharge automatically.** Euclid's gcd on Natural values with the mod guarded by the loop condition has no overflow, range or division risk, and as a procedure loop it needs no variant.

Position 192 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A Report procedure takes two Natural parameters, runs Euclid's algorithm in a while loop on local Natural variables M and N (T := M; M := N; N := T mod N), then prints "Are A and B coprime? TRUE/FALSE" using Integer'Image and an if on M = 1. Main calls Report five times with the embedded pairs; no input is read, so every execution path is covered by the Natural parameter type. About 35 lines.

## Proof obligations to watch

- **termination**: The Euclid while loop lives in a procedure, which gets no termination check, so no variant is needed.
- **division**: The mod by N is guarded by the loop condition N /= 0, which is visible just before the operation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, 'Image of scalars, procedures and while loops.

## External effects

- **console output** (allowed): Prints one result line per input pair with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 406144 of the [task](https://rosettacode.org/wiki/Coprimes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
