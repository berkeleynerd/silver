# Sort primes from list to a list

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, for-loop indexes over array ranges and a count guard, and all loops are for loops that terminate by themselves, so nothing needs an annotation; the work is only missing language surface (arrays, loops, functions, integer division, 'Image, Put).

Position 341 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the nine values as a constant array of a bounded integer subtype 0..1000, test primality with a for-loop trial division function (for D in 2 .. P-1, return False when P mod D = 0), and copy the primes into a fixed 9-element buffer with a guarded count. Sort the buffer in a procedure with nested for loops swapping when out of order, then print each element with 'Image through Put and Put_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: The prime count incremented inside a loop is a ranged subtype 0..9 and each increment is guarded by a test against the capacity, so the range check discharges.
- **index**: Sorting uses for loops over the array's own index range with a swap-based selection sort, so every index is within bounds without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, functions, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the ascending list of primes to standard output.

Assessed on 2026-10-15 against page revision 413810 of the [task](https://rosettacode.org/wiki/Sort_primes_from_list_to_a_list) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
