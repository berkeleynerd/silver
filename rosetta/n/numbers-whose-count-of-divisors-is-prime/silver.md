# Numbers whose count of divisors is prime

**Candidate: proofs plausibly discharge automatically.** All arrays, indexes and counters have declared ranges and are guarded just before use, and the only non-for loop is a stepping while loop inside a procedure, so no annotation is needed; the loop-carried count increments and the text formatting require careful guard placement, hence plausible rather than likely.

Position 379 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Build a Counts array indexed 1..99_999 of a ranged subtype by a sieve: for each I a while loop in a procedure steps J by I while J < Limit, incrementing Counts(J) under a bound guard. Then for each N from 1 to Limit-1 test whether Counts(N) is prime and not 2 using a for-loop trial division over 2..Counts(N)-1 with a Boolean flag, and print N right-justified in a fixed buffer, flushing a line every ten hits. Doing the n<1000 task first and the stretch bound as the constant Limit keeps everything fixed-size. About 70 lines.

## Proof obligations to watch

- **overflow**: The sieve counter increment Counts(J)+1 is loop-carried through array elements, so it is guarded by an explicit comparison against the component subtype's upper bound with a visible Reject outcome otherwise.
- **index**: The while loop's J := J + I is guarded by J < Limit before each use, and I and J are range-typed so J + I cannot overflow and Counts(J) is in range.
- **length**: Each 6-character column is written into a fixed 80-character line buffer at a position guarded to stay within bounds, flushing every ten entries.
- **termination**: The stepping while loop lives in a procedure so no termination check arises, and the primality test uses for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the qualifying numbers in rows of ten with Put_Line (and Put for padded columns).

Assessed on 2026-10-15 against page revision 397213 of the [task](https://rosettacode.org/wiki/Numbers_whose_count_of_divisors_is_prime) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
