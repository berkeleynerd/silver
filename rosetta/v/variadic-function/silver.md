# Variadic function

**Candidate: proofs likely to discharge automatically.** Ada models a variadic function as a procedure over an unconstrained array, and every index, length and range check follows from declared subtype ranges, 'Range loops, and guards placed before the copy, so no annotation is needed.

Position 1436 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

A record type holds a fixed-capacity String buffer with a ranged length, and an unconstrained array of these records serves as the variadic parameter of a procedure Print_All that loops over Items'Range printing each Text (1 .. Len) on its own line. Main calls Print_All with literal aggregates of different lengths, then builds an array at runtime from the command-line arguments in a for loop over 1 .. Argument_Count and passes the filled slice to Print_All. Guards reject too many arguments or arguments longer than the buffer capacity with a specified message. About 55 lines.

## Proof obligations to watch

- **index**: Printing Item.Text (1 .. Item.Len) is safe because Len is declared with subtype range 0 .. Capacity matching the buffer bounds.
- **length**: Copying a command-line argument into a fixed buffer slice is preceded by a guard that the argument length does not exceed Capacity, rejecting longer arguments visibly.
- **range**: The argument count is checked against the array capacity before the runtime list is filled, so the for-loop index over 1 .. Count stays in the array's range and too many arguments are rejected.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, unconstrained arrays, records, string indexing, string building, for loops, procedures and further arguments.

## External effects

- **console output** (allowed): Each argument passed to the variadic procedure is printed on its own line with Silver_IO.Put_Line.
- **arguments** (allowed): The runtime-constructed argument list is built from the program's command-line arguments.

Assessed on 2026-10-15 against page revision 414572 of the [task](https://rosettacode.org/wiki/Variadic_function) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
