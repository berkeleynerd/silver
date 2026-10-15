# Continued fraction/Arithmetic/G(matrix ng, continued fraction n)

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic with guards just before each product and division, and the embedded demo data stays far below the bounds, so the proofs should discharge but only with carefully placed range guards on loop-carried matrix entries.

Position 853 in the [progression](../../../../progression.md#stage-14), in stage 14.

## Approach

The state is four bounded integer variables for the matrix, and the source is either a rational (a fixed-capacity array of terms precomputed by Euclid's algorithm with a count) or sqrt(2) (term 1 then repeating 2), selected by an enumeration or record tag with no heap or pointers. A procedure loops: if both denominators are zero it stops, otherwise it outputs a term when the integer quotients agree and both denominators are nonzero, and otherwise ingests the next source term or injects infinity by copying the first column over the second. Output is capped at 20 terms and written by a procedure that formats the integers with 'Image and brackets, and composed cases (such as the nested 1/sqrt(2) then +1, then /2) are run by chaining the transform over a bounded term buffer. About 170 lines.

## Proof obligations to watch

- **overflow**: The matrix entries are loop-carried through the input and output steps, so each iteration guards that every entry and term stays within a declared bound of 10^9 before computing the products in a 64-bit type, and rejects with a printed message otherwise.
- **division**: The divisions a/b and a1/b1 are each guarded by a test that the divisor is nonzero immediately before use, and the bounded range excludes the First/-1 overflow case.
- **range**: Narrowing the computed 64-bit results back to the bounded entry subtype follows from the guard checks made just before, which the provers handle as linear bounds on the products of bounded operands.
- **termination**: The only while loops are in procedures, which get no termination check, and an explicit iteration cap with a visible reject outcome keeps the infinite sqrt(2) source finite.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building and case statements.

## External effects

- **console output** (allowed): Prints each expression and its bracketed continued fraction terms.

Assessed on 2026-10-15 against page revision 413674 of the [task](https://rosettacode.org/wiki/Continued_fraction/Arithmetic/G%28matrix_ng,_continued_fraction_n%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
