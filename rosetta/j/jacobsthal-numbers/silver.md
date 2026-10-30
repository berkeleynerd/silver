# Jacobsthal numbers

**Candidate: proofs plausibly discharge automatically.** All required values stay below 2**32, so 64-bit integers suffice and every check follows from fixed array bounds, for-loop indexes and short explicit cap guards. The nonlinear product and the loop-carried recurrence need careful guards, which makes the discharge plausible rather than routine.

Position 919 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Store the Jacobsthal numbers J(0..31) and Jacobsthal-Lucas numbers in constant-size arrays of a 64-bit integer type, filling them with a for loop whose step is guarded against exceeding a fixed cap, then derive the 20 oblong values from adjacent pairs. The first 10 primes are found by scanning J(3..31) with a for-loop trial-division function bounded by 30000, counting hits and stopping at 10, and everything is printed with Put_Line and 'Image trimmed into bounded lines. All sizes are fixed so the 715827883 largest required prime fits well inside 64-bit arithmetic. About 95 lines.

## Proof obligations to watch

- **overflow**: The recurrence J(i-1) + 2*J(i-2) is loop-carried with no invariant, so each step is guarded by an explicit cap check that rejects with a visible message, or the arrays use a 64-bit type whose range is checked against the known 32-term bound.
- **overflow**: The oblong product J(i)*J(i+1) needs both operands guarded below about 2**31 so the 64-bit product cannot overflow.
- **termination**: Trial division is written as a for loop over candidate divisors up to 30000 with an early exit, so no while-loop variant is needed in a function.
- **index**: Array indexes come from for-loop ranges over the arrays' own bounds, with the prime search bounded by the 32-entry table so index checks are routine.
- **range**: Image conversion of 64-bit values into a bounded text buffer needs a length guard so appended text never exceeds the buffer capacity.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, conditional expressions and Put without a newline.

## External effects

- **console output** (allowed): Prints the four sequences, one line per sequence or one value per line.

Assessed on 2026-10-15 against page revision 415260 of the [task](https://rosettacode.org/wiki/Jacobsthal_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
