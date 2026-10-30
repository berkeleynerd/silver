# Generalised floating point addition

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-capacity digit-array arithmetic with for loops and ranged digit types, so checks follow from types and guards with no annotations needed. Outlook is plausible rather than likely because carry and alignment indexes are loop-carried and need guards, and the task asks for a generic package.

Position 1518 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

Represent a number as a fixed-capacity array of digits (about 300 positions, to cover the over-256-digit final term) plus a bounded exponent, inside a generic package parameterized by the base. Addition aligns the exponents and adds digit by digit with a carry in a for loop, reporting a visible overflow outcome if capacity is exceeded, and multiplication by 81 is done as 81 repeated additions. A main loop builds each of the terms from -7 to 21 by prepending the 12345679 pattern, adds 1 at the matching exponent, and prints whether the result equals 1e72. About 170 lines.

## Proof obligations to watch

- **index**: Digit alignment by exponent and carry propagation index into a fixed-capacity array, discharged by explicit guards before each access and for loops over the array's own range.
- **overflow**: Digit sums and carries stay within a small ranged subtype of the generic base, and the exponent arithmetic uses bounded ranged subtypes, so the checks follow from types.
- **range**: Loop-carried carry and exponent values have no invariant, so they are kept in subtypes wide enough to hold all results, with a visible overflow outcome if capacity is exceeded.
- **other**: Generic instantiation over the base (decimal, plus balanced ternary as the optional bonus) must keep the base as a bounded generic formal so that digit-range checks prove per instance.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, for loops, while loops, procedures, functions, generics, packages, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per term from -7 to 21 reporting whether the result equals 1e72.

Assessed on 2026-10-15 against page revision 402372 of the [task](https://rosettacode.org/wiki/Generalised_floating_point_addition) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
