# 9 billion names of God the integer

**Candidate: proofs plausibly discharge automatically.** Every index and limb operation is bounded by types or guards before use and all loops are for loops in procedures, but fixed-capacity big-number arithmetic carried through nested loops needs careful shaping.

Position 1383 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Compute the 25-row triangle in a 2D Integer array with the standard recurrence T(r,c) = T(r-1,c-1) + T(r-c,c), and print each row via bounded buffers with computed leading spaces. Compute p(0..12345) using Euler's pentagonal recurrence on a static array of fixed-capacity base-10**9 limb numbers (about 20 limbs, enough for 131 digits), with for loops, an early guard when the offset goes negative, and capacity-overflow rejection. Print G(23), G(123), G(1234) and G(12345) as decimal strings built from the limbs, and skip the optional P(n) repeat and the plot. About 190 lines.

## Proof obligations to watch

- **overflow**: Limb additions and carries in the fixed-capacity big numbers stay inside a 64-bit range because each limb is a bounded subtype below 10**9 and the carry is at most a few units.
- **range**: The signed pentagonal recurrence is done by summing the added and subtracted terms into two separate non-negative big numbers and subtracting with a visible guard that rejects if the result would go negative or exceed capacity.
- **index**: Pentagonal offsets n - k(3k-1)/2 are computed in a wide integer type and guarded with a comparison to zero just before indexing the table of 12346 partition values.
- **termination**: All loops are for loops with static bounds inside procedures, so no variant is needed.
- **length**: Decimal digit output and row centering use bounded buffers whose lengths are guarded against the declared capacity before each write.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, big numbers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 25-row triangle and the G(n) values as text lines.

Assessed on 2026-10-15 against page revision 414040 of the [task](https://rosettacode.org/wiki/9_billion_names_of_God_the_integer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
