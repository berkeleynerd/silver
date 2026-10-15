# Old Russian measure of length

**Candidate: proofs plausibly discharge automatically.** All arithmetic can be kept in capped 64-bit integers with constant nonzero divisors, so only the parsing and formatting loops need careful guards and nothing needs an annotation. Floating point is avoided by fixed-scale integer output, which still meets the task's linear conversion.

Position 1452 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program holds the seven unit factors as a constant array indexed by an enumeration, in units of 0.01 mm. It parses argument 1 as a unit name and argument 2 as a decimal value with at most two fractional digits through a guarded digit loop into a capped integer, rejecting bad input. A for loop over the enumeration converts to each unit by integer multiplication and division and prints each result as integer and fractional digits built in a bounded buffer. About 130 lines.

## Proof obligations to watch

- **overflow**: Value times unit factor is discharged by capping the parsed value (at most 99999.99, stored as hundredths) in a ranged subtype so the 64-bit product and the later scaling by 100 cannot overflow.
- **index**: Digit-by-digit parsing and output buffer filling use loop-carried positions, which need explicit length guards before each index and a rejection of over-long text.
- **range**: The parse accumulator is a loop-carried value, so each step guards it against the cap before multiplying by 10 and adding the digit, rejecting input that exceeds the cap.
- **division**: Division is only by constant nonzero unit factors held in a constant array indexed by an enumeration, so the divisor is statically nonzero.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, enumerations, arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, further arguments, Put without a newline and exit status.

## External effects

- **arguments** (allowed): The unit name and the value are taken from the first two command-line arguments.
- **console output** (allowed): The conversion to each of the seven units is written line by line.
- **exit status** (allowed): Invalid unit or value text is rejected with a specified nonzero exit status.

Assessed on 2026-10-15 against page revision 412947 of the [task](https://rosettacode.org/wiki/Old_Russian_measure_of_length) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
