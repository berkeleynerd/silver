# Attractive numbers

**Candidate: proofs likely to discharge automatically.** Seven successful removals would require an input >=128, so there are at most six throughout the declared factor-count domain; neither the count guard nor seven attempts per factor suppresses a required removal. Smaller primes are exhausted before any composite factor, hence only prime factors are removed and multiplicity is counted. In particular 20 removes 2, 2 and 5. Independent prime-power multiplicity and sieve expectations establish the complete 74-value sequence through 120. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 80 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_attractive_numbers.adb: Prime_Factor_Count on 1..120 visits factors 2..120 and attempts seven guarded divisions per factor, counting each removal under Count < 6. An earlier Is_Prime function on 0..120 tests divisors 2..N/2. Main scans 1..120, assigns the count and its primality to scalar locals and prints each selected value. About 48 lines.

## Proof obligations to watch

- **division**: Every factor is at least two and every trial divisor is at least two; the guarded remaining value and fixed positive factors keep quotient and modulo operations safe.
- **range**: Count < 6 permits a result at most six; the product invariant shows the guard never blocks a required division. Remaining quotients stay in 0..120, and result counts fit the primality input domain.
- **termination**: All loops are counted; the at-most-six-removals argument proves that seven attempts per factor exhaust its multiplicity without an arbitrary cutoff.

## Language surface recorded by this assessment

Named Integer subtypes and bounded components, small nonrecursive scalar functions, bounded mutable Integer objects, scalar Boolean objects and expressions, Integer range for loops, interval-checked Integer division, scalar guard refinement and Integer image.

## External effects

- **console output** (allowed): Prints every attractive number through 120: all 74 qualifying values, one per line.

Initially assessed on 2026-10-15 against page revision 413644 of the [task](https://rosettacode.org/wiki/Attractive_numbers) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
