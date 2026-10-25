# Simulated optics experiment/Data analysis

**Candidate: proofs plausibly discharge automatically.** All integer checks follow from bounded counters and explicit rejection guards, and the floating-point part is short straight-line computation on ratios in [0,1], so it should discharge without annotations, though the ratio bounds and float formatting need careful shaping.

Position 1360 in the [progression](../../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read the file line by line in a procedure, validate each line as seven 0/1 fields, apply the geometry swap when field one is 1, and accumulate into a 4-group by 5-counter integer array (N, NL1, NL2, NR1, NR2) bounded by a documented row capacity. After reading, reject if any group is empty, then compute the four kappa values with a guarded Sqrt in a function, form the CHSH contrast, and print fixed-format float text with the theoretical 2*sqrt(2), the difference and the violation. About 170 lines.

## Proof obligations to watch

- **floating point**: Sqrt needs a non-negative argument and the sums of products of values in [0,1] must stay in range, which holds when the ratio is guarded against N = 0 and the counts are typed no larger than N.
- **range**: Each group's counts must not exceed N, which the provers cannot learn through a loop without an invariant, so the program guards the ratio and rejects inconsistent state visibly.
- **overflow**: Counters incremented per line are bounded by rejecting input once the documented row capacity is reached, so the type range discharges the increment.
- **division**: Dividing by group size N is guarded by rejecting data in which any of the four groups is empty.
- **length**: Parsing each line of seven 0/1 fields needs index guards on a bounded line buffer and a check of the line length, otherwise the line is rejected.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, floating-point images, text parsing, floating point, for loops, while loops, procedures, functions, Put without a newline, file input and exit status.

## External effects

- **files** (allowed): Reads the raw data file written by the Simulator task, named by the first argument.
- **arguments** (allowed): The first command-line argument names the data file.
- **console output** (allowed): Prints the event count, four correlation coefficients, CHSH contrast, theoretical value, difference and violation.
- **exit status** (allowed): Unreadable, malformed, empty-group or over-capacity input is rejected with a nonzero status.

Assessed on 2026-10-15 against page revision 408288 of the [task](https://rosettacode.org/wiki/Simulated_optics_experiment/Data_analysis) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
