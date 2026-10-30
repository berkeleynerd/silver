# List division

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged subtypes, for-loops and explicit guards on n, but the bounded offset arithmetic in nested loops needs careful shape so provers see the indexes stay in range, and no annotations are required.

Position 1342 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Embed a fixed-capacity Integer array (capacity about 16) with a ranged length subtype, and a procedure Divide(Data, Length, N) that first rejects N = 0 or N > Length with a visible error message and nonzero exit status. Otherwise it computes d = Length / N and r = Length mod N, then uses a for loop over parts 1..N, computing each part's start offset and size from d, r and the part number, and a nested for loop that prints the elements via 'Image with Put, commas and brackets. Main calls Divide on the embedded example lists from the task, including the oversized-n error case. About 70 lines.

## Proof obligations to watch

- **division**: Dividing by n is discharged by an explicit n = 0 guard that prints a specified rejection before the division.
- **index**: Element indexes are computed from part-start offsets, so they are derived from bounded subtype ranges or guarded to stay within the array bounds.
- **overflow**: The running start offset and the (part-1)*d product are nonlinear loop-carried values that discharge only because every operand is a small ranged subtype.
- **range**: Part sizes d and d+1 must be proven within the capacity subtype, which follows from the guard n <= length and the bounded length.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, Put without a newline and exit status.

## External effects

- **console output** (allowed): The program prints each partition and the error outcome for an oversized n.
- **exit status** (allowed): The task's error case for n greater than the list length is reported as a nonzero exit status alongside a message.

Assessed on 2026-10-15 against page revision 403364 of the [task](https://rosettacode.org/wiki/List_division) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
