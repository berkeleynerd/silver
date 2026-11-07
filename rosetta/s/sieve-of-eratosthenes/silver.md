# Sieve of Eratosthenes

**Candidate: proofs likely to discharge automatically.** The bounded sieve follows the cached task's marking algorithm, using only its allowed square-root and prime-square optimizations. K <= Limit / Base makes the Multiple guard true for every reached product, so it omits no required crossing. Expected output is independently derived by trial division. Native driver execution is retained separately from complete resulting-language assurance; the [mapping record](../../assessment-boolean-arrays-20261106.md) links the delivery evidence and preserves the original assessment provenance.

Position 56 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_sieve_of_eratosthenes.adb: explicitly initialize flags for 2 through 100, scan Base from 2 through 10, and for each surviving base cross out K * Base for K from Base through Limit / Base. Store the product in Multiple and guard Multiple <= Limit before the indexed write. Print every final surviving index with Integer'Image. No wheel, precomputed prime list or user subroutine is used. About 33 lines.

## Proof obligations to watch

- **overflow**: The product is evaluated in the admitted static operand intervals: Base in 2..10 and K in 2..50 keep Multiple in 4..500.
- **index**: The explicit bare-name guard Multiple <= Limit refines the declared 4..500 interval to 4..100 for Prime (Multiple), including within the nested loops.

## Language surface recorded by this assessment

Immutable Integer arithmetic, bounded mutable Integer objects, interval-checked Integer division, Integer range for loops, Integer image, scalar guard refinement and fixed-size Boolean arrays.

## External effects

- **console output** (allowed): Prints each prime found, one per line, with Put_Line.

Initially assessed on 2026-10-15 against page revision 415491 of the [task](https://rosettacode.org/wiki/Sieve_of_Eratosthenes) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-boolean-arrays-20261106.md).
