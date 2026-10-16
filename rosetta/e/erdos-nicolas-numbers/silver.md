# Erdős-Nicolas numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by array-bounds subtypes and fixed Limit and every check can be guarded just before use with a visible rejection, but the loop-carried sums and the multiple j need careful guards and a large fixed-capacity pair of arrays is needed.

Position 910 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Two fixed-capacity arrays indexed 1..1_600_000 hold the divisor sum (starting at 1) and the divisor count (starting at 1) for each number, filled by a sieve that adds each i to every multiple j of i. Before each update, a j = DSum(j) test (checked before adding, as in the existing solution) prints the number and its count, and it stops after 8 results, the last being 1571328 (a known bound from the task's stretch). Guards before every addition and before advancing j reject visibly rather than alter results. About 55 lines.

## Proof obligations to watch

- **overflow**: The running divisor sum and count in the sieve arrays are loop-carried values known only by their declared subtype, so each addition is preceded by a guard against the subtype's upper bound that rejects visibly if exceeded.
- **index**: The multiple j advances in a while loop, so the loop is guarded by j <= Limit and the increment is guarded by j > Limit - i before adding, keeping both the arithmetic and the array index in range.
- **termination**: The sieve is written in the main procedure, which gets no termination check, so the while loop needs no variant.
- **range**: Rendering a 7-digit number with its k count in a bounded string needs a sized buffer, which is routine given the integer subtype bounds.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): Prints each Erdős–Nicolas number with its divisor count k, one line per result.

Assessed on 2026-10-15 against page revision 412056 of the [task](https://rosettacode.org/wiki/Erd%C5%91s-Nicolas_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
