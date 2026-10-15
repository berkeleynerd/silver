# Parallel calculations

**Unlikely to prove automatically: tasking, overflow, index, division, initialization.** The arithmetic and arrays can be proved with guards and ranged subtypes. The task requires parallel threads, though, and SPARK accepts tasks and protected objects only under a Ravenscar or Jorvik profile pragma that Silver forbids, so the outlook is unlikely.

## Approach

A library package holds a constant array of the six example numbers and one Jorvik task per number. Each task factors its number by trial division in a while loop, with guards before the divisor's square test, its increment and the factor-array store, then stores the factor list and count in a protected object whose entry opens once every slot is filled. Main waits on that entry, scans with a for loop for the largest smallest factor, and prints the winning number and its factors with 'Image. About 110 lines.

## Proof obligations to watch

- **tasking**: The task requires the factorizations to run in separate threads, which in SPARK means library-level task objects and a protected result store under the Ravenscar or Jorvik profile, and selecting that profile takes a pragma that Silver source cannot contain.
- **overflow**: The trial-division test K * K <= M and the increment K + 1 act on a loop-carried divisor, so they discharge only if a guard such as K <= M / K replaces the product and a guard against K reaching the type's upper bound comes before the increment.
- **index**: The factor count is loop-carried, so each store into the fixed 31-slot factor array needs a guard that the count is below capacity, leading to a visible rejection that real inputs never reach.
- **division**: M mod K and M / K discharge because K's subtype starts at 2.
- **initialization**: The protected result array has to be initialized by its declaration, and the main procedure must wait on a protected entry until every task has reported, so it reads only results that have been written.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, packages, tasking, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the winning number and its prime factors.

Assessed on 2026-10-15 against page revision 414379 of the [task](https://rosettacode.org/wiki/Parallel_calculations) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
