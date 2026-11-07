# 10001th prime

**Candidate: proofs likely to discharge automatically.** All arithmetic is on small ranged integers with guards before each increment and multiply, and all loops sit in procedures so no termination annotation is needed, so the proofs should discharge from types and guards.

Position 194 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

The Main procedure keeps a Candidate and a Count in bounded integer subtypes and loops with while in a single procedure body, testing each odd candidate by trial division with a divisor that grows by 2 while its square does not exceed the candidate. A guard stops the search with a specified message if the candidate would pass the declared bound, and the result is converted to text through a small bounded digit buffer and printed with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The candidate, divisor and square are held in a subtype bounded at 200_000 and the divisor loop exits once its square exceeds the candidate, so Temp*Temp stays below about 4*10^10 in a 64-bit type and a guard before the multiply keeps it in range.
- **termination**: The trial-division loop and the outer search loop live in a procedure, which gets no termination check, so no variant is needed.
- **range**: The prime counter and candidate are incremented only after a guard against their subtype upper bounds, and reaching the bound without finding the target yields a visible rejection message.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 10001st prime (104743) to standard output.

Assessed on 2026-10-15 against page revision 415330 of the [task](https://rosettacode.org/wiki/10001th_prime) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
