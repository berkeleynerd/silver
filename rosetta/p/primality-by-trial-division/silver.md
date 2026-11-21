# Primality by trial division

**Candidate: proofs likely to discharge automatically.** The cached task explicitly requires a Boolean function, excludes 1 and nonpositive inputs, and permits other trial-division loops. The driver covers all candidates in its declared domain. For 2 and 3 the divisor loop is empty; every composite N >= 4 has a proper divisor between 2 and N/2. Guard refinement bounds N / 2; every executed divisor is at least 2. There is no answer table, floating-point square root, early return, while loop, extra procedure or computed String buffer. Independent composite marking derives the 25 expected prime lines. The [reconciliation](../../../rosetta/assessment-scalar-functions-20261107.md) distinguishes static task/source review and retained native application evidence from the [capability assurance record](../../../docs/scalar-functions.md).

Position 65 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_primality_by_trial_division.adb unchanged: Candidate is Integer range -10 .. 100; Is_Prime(N : in Candidate) returns Boolean. Its local Prime starts False. If N >= 2, set Prime True and test each Divisor in 2 .. (N / 2), clearing Prime on an exact divisor. Return the final flag once. Main calls Is_Prime as the whole RHS of a Boolean assignment for every candidate and prints only primes with Integer Image and Put_Line. About 28 lines.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, scalar Boolean objects and expressions, Integer range for loops, interval-checked Integer division, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Main prints exactly the prime candidates in the declared -10..100 domain, one Integer Image per line.

Initially assessed on 2026-10-15 against page revision 414879 of the [task](https://rosettacode.org/wiki/Primality_by_trial_division) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../../rosetta/assessment-scalar-functions-20261107.md).
