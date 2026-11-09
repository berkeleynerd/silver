# Yellowstone sequence

**Candidate: proofs likely to discharge automatically.** Everything is bounded integer arithmetic and array indexing in procedures with guards before each access, and the extra plot is optional, so no annotation or function variant is required. The only non-routine point is the candidate search limit, which a visible Reject branch handles; the actual maximum in the first 30 terms is 51, well within the table.

Position 221 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a Boolean array Used (1 .. 200) and a 30-element array of the sequence values, both in a bounded positive subtype; seed a(1..3) = 1..3, then for each n from 4 to 30 scan upward from 1 with a while loop (condition guarded by Candidate < Limit) for the smallest unused value whose GCD, computed by an Euclid while-loop procedure, is 1 with a(n-1) and greater than 1 with a(n-2). If no candidate is found within the limit the program rejects visibly; otherwise it marks Used and prints each value with 'Image via Put, ending with a newline. About 70 lines.

## Proof obligations to watch

- **index**: The Used array is indexed by the candidate, so the search loop tests Candidate < Limit in its condition before every access and rejects visibly if the table is exhausted.
- **overflow**: The candidate increment and the Euclid remainder values live in a bounded subtype with a Limit guard, so the types alone bound them even though the loop carries no invariant.
- **termination**: GCD is a procedure with a while loop (no termination check is generated), and the search loop is also in a procedure, so no variant is needed.
- **division**: The mod operation sits inside a while loop whose condition is B /= 0, which is the guard placed just before the operation.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 30 Yellowstone numbers, space separated, on one line.

Assessed on 2026-10-15 against page revision 414996 of the [task](https://rosettacode.org/wiki/Yellowstone_sequence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
