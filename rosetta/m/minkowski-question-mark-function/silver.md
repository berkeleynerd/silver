# Minkowski question-mark function

**Candidate: proofs plausibly discharge automatically.** Everything can be done with bounded integer arithmetic in procedures with capped loops and guards before each addition or multiplication, so no annotation is needed, but several loop-carried values need careful overflow guards.

Position 421 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Represent numbers as bounded integer numerator/denominator pairs in a ranged subtype; ?(p/q) is computed exactly by expanding the continued fraction with Euclid's algorithm, choosing the form ending in 1, and emitting run-length binary bits into a dyadic numerator/denominator, while ?^-1 walks the Stern-Brocot tree bit by bit with mediants under overflow guards. The program embeds the examples (31/7, Fibonacci convergents of phi, -5/9, round trips), uses for loops where possible and capped while loops only inside procedures, and prints results as text with Integer'Image-built rational strings. About 150 lines.

## Proof obligations to watch

- **overflow**: Mediant numerators and denominators and the cross-multiplication comparisons are carried through loops, so the program keeps them in a bounded subtype (for example below 2**30) and stops refining with a visible 'precision limit reached' outcome when a guard before each addition or product fails.
- **termination**: All iteration (Stern-Brocot descent, Euclid continued-fraction expansion, bit-doubling) sits in procedures with explicit iteration caps, so no termination check applies.
- **range**: The inverse of a non-dyadic value such as -5/9 is approximated to a fixed number of bits (the 'is this really the exact inverse' question is answered by the stated precision), and the rational input is validated (denominator nonzero) before use.
- **other**: phi and the root of 6x^2+14x+3=0 are irrational so cannot be held exactly; they are represented by integer convergents (Fibonacci ratios, and a bounded integer bisection), which approximates the task's 'don't worry about precision' allowance without floating point.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the computed question-mark values, inverse values and round-trip checks as text lines.

Assessed on 2026-10-15 against page revision 414344 of the [task](https://rosettacode.org/wiki/Minkowski_question-mark_function) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
