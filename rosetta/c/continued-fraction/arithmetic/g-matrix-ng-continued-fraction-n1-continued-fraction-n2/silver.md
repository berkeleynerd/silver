# Continued fraction/Arithmetic/G(matrix ng, continued fraction n1, continued fraction n2)

**Candidate: proofs plausibly discharge automatically.** The algorithm is iteration over a bounded state with explicit zero-denominator and magnitude guards, so no annotations are required, but the coefficient growth needs careful range guards or fixed-capacity big numbers, which makes discharge plausible rather than likely.

Position 1385 in the [progression](../../../../progression.md#stage-25), in stage 25.

## Approach

Each continued fraction is a fixed-capacity array of Integer terms (sqrt(2), 1/2 style examples are embedded), and the eight-coefficient NG state is a record of bounded integers updated in a procedure-based main loop with a fixed iteration budget. Each step checks whether the four floor quotients agree (guarding b /= 0), emits a term if so, and otherwise ingests a term from N1 or N2, injecting infinity when a source is exhausted. After each update a magnitude guard stops with a printed outcome if any coefficient would exceed the limit, and terms are printed with Put_Line and 'Image. About 170 lines.

## Proof obligations to watch

- **overflow**: The eight matrix coefficients grow with every input term, so they are held in fixed-capacity big integers, or in a 64-bit range with a guard that stops processing with a visible 'term limit reached' outcome when any coefficient exceeds a threshold.
- **termination**: Non-terminating products such as sqrt(2)*sqrt(2) are bounded by a fixed term budget in a for loop or a procedure-only while loop, so no variant is needed.
- **division**: Floor division of a by b and the comparison of a1/b1, a2/b2 and a/b are each guarded by an explicit b /= 0 test before use, with zero denominators treated as infinity.
- **range**: Choosing between N1 and N2 by comparing fractions needs cross-multiplication, which stays bounded only if the coefficients are capped by the same threshold guard.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, case statements, string building, 'Image of scalars, Put without a newline and big numbers.

## External effects

- **console output** (allowed): Prints the resulting continued-fraction terms for the example operations.

Assessed on 2026-10-15 against page revision 414130 of the [task](https://rosettacode.org/wiki/Continued_fraction/Arithmetic/G%28matrix_ng,_continued_fraction_n1,_continued_fraction_n2%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
