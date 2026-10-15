# Statistics/Normal distribution

**Candidate: proofs plausibly discharge automatically.** Everything is bounded and loops are for loops in procedures, so index and termination checks are routine, but floating-point log, sqrt and cos with accumulated sums need careful range guards for the provers to discharge the float overflow and domain checks. Outlook is plausible rather than likely because of the float-heavy arithmetic and float-to-index conversion.

Position 1307 in the [progression](../../../progression.md#stage-22), in stage 22.

## Approach

Embed a fixed-size sample array of Float (say 1000), fill it with a modular-type LCG feeding a Box-Muller transform using a guarded uniform value in (0,1], then compute mean and standard deviation in for loops. Bin each sample into a fixed array of 12 counters via range guards with explicit under and overflow bins, and print mean, sd and star bars built in a bounded buffer with Put. The task's part 2 (native support) is satisfied by a comment-free note in the output text, since Ada has no native normal generator. About 110 lines.

## Proof obligations to watch

- **floating point**: The Box-Muller transform needs log, sqrt and cos of values bounded away from zero, and each result must be shown finite, so the uniform draw is built from an integer in 1..2**16 divided by 2.0**16 and every float operand is range-guarded.
- **overflow**: The sum and sum of squares over a few thousand samples stay within bounds only if each sample is clamped to a declared float range, which a guard can express as a visible out-of-range histogram bin without altering the statistics.
- **overflow**: The deterministic LCG uses a modular type so wraparound is defined and cannot fail a check.
- **index**: The histogram bin index is computed from a float, so a guard on the value range selects explicit under/overflow bins before conversion to the index type.
- **floating point**: Divisions by the sample count and the square root of a variance need guards showing the count is positive and the variance is nonnegative, which a nonlinear sum-of-squares loop makes hard for provers.
- **termination**: All loops are for loops or live in procedures, so no variant is needed.

## Language surface beyond today's Silver

Integers, integer division, modular types, ranged subtypes, floating point, arrays, records, for loops, while loops, procedures, functions, string building, 'Image of scalars, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): Prints the mean, standard deviation and a text histogram with Put_Line and Put.

Assessed on 2026-10-15 against page revision 414516 of the [task](https://rosettacode.org/wiki/Statistics/Normal_distribution) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
