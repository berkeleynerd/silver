# Pan base non-primes

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, for-loop indexes and one divide guard, but the nested base and trial-division loops and the unrolled digit evaluation need careful shaping, so discharge is plausible rather than routine.

Position 414 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the limit 1000 and loop n over 3..1000, splitting n into up to four digits; for each base 2..n (skipping bases where a digit is not below the base) evaluate the value with an unrolled Horner step in a ranged subtype and test primality by trial division in a for loop with early exit, marking n as pan-base composite if no base gives a prime. Collect the first 40 and the first 20 odd ones in fixed arrays, keep odd and total counts, and print them with Image-based decimal conversion into bounded buffers and Put_Line, plus integer percentages with a visible two-decimal format. About 130 lines.

## Proof obligations to watch

- **overflow**: Evaluating digits in a base loop-carries the value, so the program unrolls it over at most four digits with ranged subtypes (digits 0..9, base 2..1000, value up to 10**12) so each intermediate is bounded by types alone.
- **overflow**: Trial division uses a for loop index over 2..1_000_000 with an exit when i*i exceeds the value, so i*i stays below 10**12 by the index range.
- **range**: Percentages computed as integer count*10000/total need the total guarded to be non-zero and the counts typed with ranges up to 1000, which the program does with an explicit guard.
- **index**: Result arrays of 40 entries are filled only after a guard that the stored count is below the capacity, otherwise the loop stops collecting.
- **termination**: Primality testing is kept in a function using only for loops, which terminate on their own, so no variant is required.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 40 and first 20 odd pan-base non-primes, the count up to 1000, and the odd/even percentages.

Assessed on 2026-10-15 against page revision 413829 of the [task](https://rosettacode.org/wiki/Pan_base_non-primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
