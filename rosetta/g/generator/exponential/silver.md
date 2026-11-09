# Generator/Exponential

**Candidate: proofs likely to discharge automatically.** Every arithmetic check is protected by a guard placed right before it (dividing by a nonzero base to bound the multiply, and comparing the counter with 'Last), and the only while loop is in a procedure. Because of this, no annotation is needed. The only check that is not purely linear is the standard Acc <= Last / N bound before Acc * N, which provers routinely discharge.

Position 606 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

Each power generator is a record holding the next base (Long_Long_Integer) and the exponent m, and a procedure Next(Gen : in out, Value : out, Exhausted : out) computes base**m by a guarded multiply loop and then advances the base. The filtered generator is a record holding a squares generator, a cubes generator and the last cube; its Next procedure uses a while loop that advances the cube stream while it is below the square and skips squares equal to a cube. Main drops 20 values with a for loop and prints the next 10 with 'Image, printing an exhaustion message if any generator reports that its integer range is used up. About 90 lines.

## Proof obligations to watch

- **overflow**: The power accumulator in the exponent for loop is multiplied only after a guard Acc <= Long_Long_Integer'Last / N, and the base counter is incremented only after a test against its type's 'Last, so exhaustion sets a visible Exhausted flag instead of overflowing.
- **division**: The overflow guard divides by the base N only on the branch where N /= 0, with zero handled separately because any positive power of 0 is 0.
- **initialization**: Each Next procedure assigns its out Value and Exhausted parameters on every path, including the paths that report exhaustion.
- **termination**: The filter's while loop that advances squares past matching cubes sits in a procedure, so GNATprove raises no termination check, and the loop always stops once a generator reports exhaustion.

## Language surface recorded by this assessment

Integers, integer division, Boolean objects, records, procedures, for loops, while loops and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the 10 filtered values after dropping the first 20.

Assessed on 2026-10-15 against page revision 415168 of the [task](https://rosettacode.org/wiki/Generator/Exponential) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
