# Neighbour primes

**Candidate: proofs likely to discharge automatically.** Every value is bounded by declared subtypes (p, q at most 600, r at most about 253,000), all loops are for loops or in procedures, and the only non-routine part is guarded string padding, so checks discharge from types and guards.

Position 360 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Define a function Is_Prime(N) over a bounded subtype that loops for D in 2..500 with a guard D*D <= N before testing N mod D, and a procedure that scans P in 3..499 with a for loop, finds the next prime Q by a for loop over P+1..600, and computes R = P*Q+2 in a range-bounded Integer. Each qualifying triple is formatted into a fixed 80-character line by left-padding the 'Image text to widths 3, 4 and 7 and printed with Put_Line after a header and a dashed rule. About 75 lines.

## Proof obligations to watch

- **overflow**: p*q+2 is at most about 253,000 because p and q are subtypes bounded by 600, so it fits in Integer and the product bounds follow from the types.
- **termination**: Primality testing uses a for loop with exit over a fixed divisor range, and the outer scan over p is a for loop, so no while-loop variant is needed in functions.
- **index**: Right-justified padding writes into a fixed 80-character buffer using Image text whose length is bounded by the subtype, discharged with explicit length guards before each slice.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, procedures, for loops, while loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the header and one formatted line per qualifying prime pair.

Assessed on 2026-10-15 against page revision 406214 of the [task](https://rosettacode.org/wiki/Neighbour_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
