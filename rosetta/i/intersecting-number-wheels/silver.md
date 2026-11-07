# Intersecting number wheels

**Candidate: proofs likely to discharge automatically.** All checks follow from ranged position subtypes, for-loop indexes over the array ranges and guards placed just before character lookups, and the cyclic-reference risk is handled by a bounded loop in a procedure.

Position 537 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Each wheel group is embedded as constant Strings (for example "1B2" and "34") with a small array of per-wheel positions of a ranged subtype and a lengths array. A procedure Next_Term runs a for loop of bounded depth: it reads the current character of the wheel, advances that wheel's position with an if-wrap, and either takes a digit as the result or maps a letter name to its wheel index after a range guard and continues. A for loop over 20 terms appends each digit to a fixed 39-character output String, which is written with Put_Line for each of the four groups, and a reference chain longer than the depth bound gives a specified Reject outcome. About 110 lines.

## Proof obligations to watch

- **index**: Mapping a wheel-name character to a wheel index and reading the current character both need explicit range guards, which are placed just before each use and discharge directly.
- **termination**: Name-reference chains that could cycle forever are cut off by a bounded for loop inside a procedure, so no variant is needed and an over-deep chain is rejected visibly.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each wheel group and its first twenty generated terms.

Assessed on 2026-10-15 against page revision 414269 of the [task](https://rosettacode.org/wiki/Intersecting_number_wheels) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
