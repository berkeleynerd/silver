# Engel expansion

**Candidate: proofs plausibly discharge automatically.** Because the Engel step keeps the denominator fixed and shrinks the numerator, everything fits in 64-bit ranged integers with guards and no products or big numbers, so proofs should discharge with careful range subtypes and guards. Outlook is plausible rather than likely because of the loop-carried numerator range checks and the fixed term capacity.

Position 282 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Each rational is an embedded numerator and a power-of-ten denominator (pi, e, sqrt 2 as decimal approximations), and a procedure with a while loop repeatedly takes a = ceil(d/n) via (d+n-1)/n and the new numerator n-1-((d+n-1) mod n) while n > 0, storing terms in a fixed-capacity array of positive integers. A second procedure walks the array backwards computing n = (n+d)/a, with a guard that the result stays within the numerator range, and the program prints the first 30 terms and the recovered n/d next to the original using 'Image and concatenation. The stretch high-precision part is omitted as optional. About 120 lines.

## Proof obligations to watch

- **overflow**: Each rational is held as numerator over a fixed power-of-ten denominator in a 64-bit range subtype capped near 10**16, so n+d and (d+n-1) cannot overflow, and the ceiling step uses the remainder form n' = n-1-((d+n-1) mod n) so no product is formed.
- **range**: The new numerator n-1-r relies on the prover knowing r < n from the mod bound, which is routine, but the loop-carried n is known only by its subtype so the guard n > 0 sits just before each division.
- **index**: The term array has fixed capacity (e.g. 100) and the loop guards the count before each store, printing a visible 'capacity exceeded' outcome rather than dropping terms.
- **overflow**: The reverse conversion computes n = (n + d) / a backwards, and the loop-carried result is checked against d with a visible rejection before it is stored in the ranged subtype.
- **termination**: All while loops are inside procedures, which receive no termination check, and the numerator strictly decreases so the loop also terminates in practice.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each rational, its Engel terms, the term count and the round-trip result.

Assessed on 2026-10-15 against page revision 414183 of the [task](https://rosettacode.org/wiki/Engel_expansion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
