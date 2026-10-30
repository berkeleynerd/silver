# Arithmetic/Integer

**Candidate: proofs plausibly discharge automatically.** Widening to 64 bits plus a zero-divisor guard discharges all the basic operations routinely. Only the guarded multiply in the power loop relies on nonlinear reasoning, so proof depends on careful program shape rather than annotations, which makes the outlook plausible.

Position 1439 in the [progression](../../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Main reads the first two arguments, validates and parses them to Integer, and rejects any malformed value. It also rejects a zero divisor. Each operand is widened to a 64-bit type to print the sum, difference, product, quotient (rounds toward zero), mod (takes the sign of the second operand) and rem (takes the sign of the first operand). A for loop from 1 to B computes the power, with a guarded multiplication that sets a Boolean overflow flag and prints a visible "exceeds capacity" line rather than wrapping, and a negative exponent prints a stated "not an integer" outcome. About 60 lines.

## Proof obligations to watch

- **overflow**: Sum, difference, product and Integer'First / -1 are computed after converting both Integer operands to a 64-bit type, where their results always fit by type range.
- **division**: A zero second operand is rejected with a visible message before /, mod and rem, so the divisor check is discharged by the guard.
- **overflow**: The power loop multiplies a loop-carried accumulator only when abs P <= Limit / abs A, a nonlinear guard that provers usually but not always turn into the bound on P * A.
- **range**: The accumulator is declared in a symmetric range -Limit .. Limit so abs P cannot overflow, and a negative exponent gets a visible 'undefined' line instead of evaluating the power.
- **other**: Parsing the arguments must go through an admitted validating operation so that malformed or out-of-range text leads to Reject rather than a Constraint_Error from 'Value.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, 'Image of scalars, text parsing, further arguments and for loops.

## External effects

- **console output** (allowed): The sum, difference, product, quotient, remainder, power and the notes on rounding and remainder sign are printed with Put_Line.
- **arguments** (allowed): The two integers come from the user as the first two command-line arguments.

Assessed on 2026-10-15 against page revision 412653 of the [task](https://rosettacode.org/wiki/Arithmetic/Integer) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
