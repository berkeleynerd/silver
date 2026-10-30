# Sequence of primes by trial division

**Candidate: proofs likely to discharge automatically.** The source uses finite Integer loops and a Boolean flag; divisor bounds exclude zero, including the empty first inner loop. The expected 25 primes through 100 are derived independently by marking composite multiples. The delivery mapping is staged contingent on the complete #291 assurance, native validation and independent review checkpoint; this static reconciliation supplies no such evidence.

Position 33 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The driver samples/rosetta_sequence_of_primes_by_trial_division.adb scans Candidate in 2..100. It resets a Boolean Prime flag, tries every Divisor in 2..(Candidate - 1), clears the flag when Candidate mod Divisor = 0 and prints each surviving candidate with Integer Image. The inner loop is empty for 2. It uses the task-permitted finite bound and actual trial division. About 17 lines.

## Language surface recorded by this assessment

Scalar Boolean objects and expressions, Integer range for loops, interval-checked Integer division and Integer image.

## External effects

- **console output** (allowed): Prints each prime found in the embedded range to standard output.

Initially assessed on 2026-10-15 against page revision 413905 of the [task](https://rosettacode.org/wiki/Sequence_of_primes_by_trial_division) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-30 by Codex through targeted source review; see the [review record](../../../rosetta/assessment-boolean-objects-20261030.md).
