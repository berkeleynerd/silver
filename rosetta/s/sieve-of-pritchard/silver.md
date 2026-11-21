# Sieve of Pritchard

**Candidate: proofs plausibly discharge automatically.** All arithmetic and indexes are bounded by Limit-ranged subtypes and explicit comparisons, so checks should discharge without annotations, though several loop-carried values need careful typing and guarding.

Position 913 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed Limit = 150 and keep the wheel as a Boolean array indexed 1..Limit, with step, prime, nlimit and np as variables of a subtype 1..Limit (or a slightly wider range where sums occur). Main runs the Pritchard loop with while loops for growing the wheel and a for loop over the array copy for removal, testing prime*prime <= Limit instead of a square root, and each index is guarded by a comparison just before use. The collected small primes and the surviving wheel members are then printed with Put_Line, using Image to render each number. About 70 lines.

## Proof obligations to watch

- **index**: Every members(n) access is guarded by n <= nlimit or n <= Limit just before use, with nlimit declared in a subtype range 1..Limit so the bound follows from types.
- **overflow**: The products prime*i and step*prime and sums n+step involve only loop-carried values typed in ranges bounded by 150, so they fit in Integer, but the provers must see the subtype bounds after each iteration.
- **range**: Assigning np, prime and nlimit back into narrow subtypes needs a guard such as the min of step*prime and Limit computed with an if before the assignment.
- **termination**: The while loops live only in the Main procedure, which gets no termination check, and the real step count is still finite by construction.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, conditional expressions, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints the primes up to 150, one per line or as a built line, via Silver_IO.

Assessed on 2026-10-15 against page revision 414468 of the [task](https://rosettacode.org/wiki/Sieve_of_Pritchard) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
