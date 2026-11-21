# Averages/Mean angle

**Candidate: proofs plausibly discharge automatically.** Indexing and bounds are routine, but the task fundamentally needs floating-point trigonometry whose discharge depends on admitted elementary-function contracts and bounded accumulators, so it is plausible rather than likely; the 90/180/270/360 case is handled by an explicit guard rather than an exception.

Position 972 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

Embed each angle list as a constant array of a bounded float subtype in degrees (capacity 8) and compute the sin and cos sums in a for loop over the array's own range, using bounded accumulator types. Before calling Arctan, guard on whether both sums are near zero and print an explicit 'undefined' outcome in that case; otherwise convert the result to [0,360) and print it with two decimals via scaled-integer formatting. About 70 lines.

## Proof obligations to watch

- **floating point**: Sin, Cos and Arctan need admitted library operations with verified range postconditions and an Arctan precondition that the arguments are not both zero, and the prover must show the sum of at most 8 bounded terms cannot overflow.
- **range**: Loop-carried Sin and Cos accumulators are known only by their declared type range, so that type must be bounded wide enough for the maximum list length, which is a documented fixed capacity.
- **other**: The list [90,180,270,360] has a sum of essentially zero, so the program guards on a small magnitude threshold and prints a specified 'mean undefined' outcome rather than raising Argument_Error, which keeps the behavior visible and faithful.
- **floating point**: Printing a degree value to two decimals needs a float-formatting routine that stays within a bounded buffer, for example by scaling to an integer in a declared range and converting it to text.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, floating-point images, arrays, for loops, procedures, functions, Boolean objects, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the mean angle (or an undefined notice) for each of the three embedded lists.

Assessed on 2026-10-15 against page revision 413972 of the [task](https://rosettacode.org/wiki/Averages/Mean_angle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
