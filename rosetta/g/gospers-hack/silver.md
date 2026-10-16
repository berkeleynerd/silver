# Gosper's hack

**Candidate: proofs likely to discharge automatically.** All arithmetic is on a modular type so no overflow or range check can fail, the only division is guarded by a nonzero test, and no loop needs an invariant since the for loop is fixed at ten iterations.

Position 1270 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Declare a 32-bit modular type and a function Next that computes c = x and (-x), r = x + c and ((r xor x) / 4) / c or r, after guarding x /= 0 and r >= x. A procedure Show takes a start value, loops ten times with a for loop carrying x, and prints the start and each successor with Put and 'Image text; Main calls Show for 1, 3, 7 and 15. About 45 lines.

## Proof obligations to watch

- **division**: The lowest-set-bit value c is the divisor, so the program guards that x is nonzero just before dividing and reports a specified rejection otherwise.
- **overflow**: The sum x + c on a modular type cannot fail a check, and a guard that the sum is not smaller than x makes the wrap a visible rejected outcome instead of a silent wrong answer.

## Language surface beyond today's Silver

Modular types, integer division, for loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints four lines of ten successors each.

Assessed on 2026-10-15 against page revision 414651 of the [task](https://rosettacode.org/wiki/Gosper's_hack) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
