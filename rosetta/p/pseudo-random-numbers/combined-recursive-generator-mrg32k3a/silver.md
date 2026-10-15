# Pseudo-random numbers/Combined recursive generator MRG32k3a

**Candidate: proofs plausibly discharge automatically.** The integer recurrences use only constant coefficients on range-bounded state and mod by positive constants, so overflow and range checks follow from types. Two places rely on careful shape, though: the float-to-index conversion and the loop-carried bucket counters each need an explicit guard with a visible error branch, which makes the outlook plausible rather than likely.

Position 876 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

The generator state is two 3-element arrays of declared 64-bit ranged types (0 .. m1 and 0 .. m2), updated by a Seed procedure and a Next_Int procedure with in out state and an out result, since functions cannot modify state; Next_Float is a procedure that converts Next_Int's result to Long_Float and divides by d. Main runs a for loop of 5 printing Next_Int for seed 1234567, then a for loop of 100_000 that scales Next_Float by 5.0, guards the scaled value into [0, 5) before taking Floor and converting to a bucket index 0 .. 4, and increments a guarded counts array, finally printing each bucket with 'Image. About 75 lines.

## Proof obligations to watch

- **overflow**: The linear combinations such as 1403580*x1(1) - 810728*x1(2) stay below about 2**54 because the state components are typed 0 .. m1 and the coefficients are constants, so a 64-bit declared range type discharges them from types alone.
- **range**: Results of mod m1 and mod m2 land in 0 .. m1-1 and 0 .. m2-1, so storing them back into the ranged state arrays and forming z + 1 in 1 .. m1 follow from the mod semantics with a positive constant divisor.
- **floating point**: Converting Floor(Next_Float * 5.0) to a bucket index needs the value in 0 .. 4, which the prover may not derive through the float division, so an explicit guard (0.0 <= Scaled and Scaled < 5.0) with a visible rejection branch that never fires is placed just before the conversion.
- **overflow**: Each bucket count is a loop-carried accumulator whose bound across 100_000 iterations needs an invariant, so the increment is guarded by Counts(J) < Count_Type'Last with a visible error outcome in the else branch.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, floating point, procedures, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the five integers from seed 1234567 and the five bucket counts from seed 987654321.

Assessed on 2026-10-15 against page revision 413862 of the [task](https://rosettacode.org/wiki/Pseudo-random_numbers/Combined_recursive_generator_MRG32k3a) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
