# Safe and Sophie Germain primes

**Candidate: proofs likely to discharge automatically.** The only loop-carried value is Count, which a guard placed just before the increment protects; every other check follows from static for-loop index ranges and a ranged parameter subtype. Termination needs no variant because there are no while loops and no recursion.

Position 312 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Main has a for loop over the candidates P in 2 .. 1500, a bound that is documented and large enough because the 50th Sophie Germain prime is 1499. Inside it, a guard `Count < 50 and then Is_Prime (P) and then Is_Prime (2 * P + 1)` controls printing P with Integer'Image and Put_Line and incrementing Count. Is_Prime is a side-effect-free function whose parameter subtype is 1 .. 3001; it does trial division with a for loop over D in 2 .. 55, stopping when D * D > N, and uses N mod D with a divisor that is never zero. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Count + 1 is guarded by a test of Count < 50 just before the increment, and 2 * P + 1 and D * D stay small because P is a for-loop index over 2 .. 1500 and D is a for-loop index over 2 .. 55.
- **range**: Passing 2 * P + 1 to Is_Prime, whose parameter subtype is 1 .. 3001, follows directly from the static range of the for-loop index P.
- **termination**: Is_Prime uses only a for loop that exits early on D * D > N or a found divisor, so the function needs no variant to prove termination.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the first 50 Sophie Germain primes to standard output.

Assessed on 2026-10-15 against page revision 406225 of the [task](https://rosettacode.org/wiki/Safe_and_Sophie_Germain_primes) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
