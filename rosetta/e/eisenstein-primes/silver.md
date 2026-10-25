# Eisenstein primes

**Candidate: proofs likely to discharge automatically.** Every check follows from declared ranges on a and b, a bounded norm search and a counter guarded before use, and the only loops are for loops, so no annotation is needed; the main effort is bounded string formatting of signed fixed-decimal values.

Position 896 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Use ranged integer subtypes for a and b in -30..30 and a function Is_Prime using a for loop over divisors up to the norm, plus the axis rule (a=0, b=0 or a=b needs |c| prime with c mod 3 = 2, otherwise the norm must be prime). The main procedure loops norms from 1 to 400 and, for each, scans b then a ascending, so ties come out ordered by imaginary then real part, and stops after 100 primes. Each value is printed with exact integer arithmetic as real = a - b/2 and imag = b*sqrt(3)/2 using a scaled integer constant for sqrt 3, avoiding floating point; the plot stretch is omitted. About 95 lines.

## Proof obligations to watch

- **overflow**: a*a - a*b + b*b is bounded because a and b are declared in -30..30, and the scaled imaginary part b*17321 is bounded by the same range.
- **range**: The prime counter is guarded by a comparison against 100 just before each increment and output, so it never leaves its declared range.
- **length**: Each output line is assembled in a fixed-size buffer sized for the widest possible sign, digits and decimals, so concatenation lengths are static.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, procedures, 'Image of scalars, string building and conditional expressions.

## External effects

- **console output** (allowed): The 100 primes are printed as text lines of complex values.

Assessed on 2026-10-15 against page revision 414175 of the [task](https://rosettacode.org/wiki/Eisenstein_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
