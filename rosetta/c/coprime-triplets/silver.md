# Coprime triplets

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, 1..49 bounded loops and a guard before each increment, and the only while loops sit in procedures, so no annotation is needed.

Position 213 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Keep Seq as an array (1..50) of Candidate (subtype 1..49) plus a Used Boolean array indexed 1..49, seeded with 1 and 2; an outer while loop in the main procedure scans candidates 1..49 with a for loop, computing gcd against the last two terms via a gcd procedure (while b /= 0 with mod), appends the first unused coprime candidate, and exits when none is found. After the loop it prints the count and each term by building the line in a bounded String buffer using 'Image-style digit conversion and Put_Line. About 60 lines.

## Proof obligations to watch

- **termination**: Euclid's gcd uses a while loop, so it is a procedure with out parameter (procedures get no termination check), keeping the loop out of any function.
- **overflow**: The term counter is a ranged subtype 0..50 and is incremented only under an explicit guard count < 50, with a visible stop otherwise.
- **index**: Sequence array is indexed 1..50 and the predecessor lookups count-1 and count are guarded by count >= 2, and the used-flag array is indexed by values in 1..49 by type.
- **division**: The mod in gcd is guarded by the while condition b /= 0, so the divisor is provably nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the term count and the sequence terms to standard output.

Assessed on 2026-10-15 against page revision 390743 of the [task](https://rosettacode.org/wiki/Coprime_triplets) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
