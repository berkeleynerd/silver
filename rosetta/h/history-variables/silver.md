# History variables

**Candidate: proofs likely to discharge automatically.** Every check comes from declared index and count ranges, or from a capacity guard placed just before the increment, and the program has no while loops, recursion or nonlinear arithmetic, so the proofs should discharge without annotations.

Position 590 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A history variable is a record holding a fixed-capacity array of Integer values and a Count of subtype 0 .. Capacity. A Set procedure appends a value after the guard Count < Capacity and reports a visible rejection otherwise. Main assigns 3, 7 and 9, displays the history in a for loop over 1 .. Count without changing it, then recalls each of the three values by generation using 'Image and Put_Line. About 50 lines.

## Proof obligations to watch

- **index**: History slots are indexed by a for loop over 1 .. Count, where Count's subtype is 0 .. Capacity and the array is 1 .. Capacity, so each index check follows from the declared ranges.
- **range**: Set increments Count only after the guard Count < Capacity, and a full history gives a visible rejection message instead of a silent overwrite, so the range check on Count discharges.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, records, procedures, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the stored history and then the three recalled values to standard output.

Assessed on 2026-10-15 against page revision 413191 of the [task](https://rosettacode.org/wiki/History_variables) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
