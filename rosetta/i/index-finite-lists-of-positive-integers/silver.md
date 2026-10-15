# Index finite lists of positive integers

**Candidate: proofs plausibly discharge automatically.** Bijective numeration needs only bounded integer arithmetic and loops, with every overflow and capacity check dischargeable by a guard just before the operation and a visible rejection outcome, but the loop-carried accumulator and output-buffer building make it depend on careful program shape. The "arbitrarily large" requirement is met only up to a documented fixed bound, which the Oracle permits as a resource limit.

Position 414 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Lists are held as a fixed-capacity array of elements in 1..M plus a length, and rank uses bijective base-M numeration (rank := rank*M + x) in a for loop, with a guard before each step that rejects the list if the result would exceed a 64-bit limit, which is a documented resource limit. Unrank is a procedure with a while loop that repeatedly takes x := (n-1) mod M + 1 and n := (n-1)/M, filling the array in reverse under a capacity guard. The demonstration uses embedded example lists (random choice replaced by a deterministic pseudo-random or fixed data) and the extra-credit table of unrank(0..10), printed with Image-based text building. About 110 lines.

## Proof obligations to watch

- **overflow**: The loop-carried rank accumulator is only bounded by its type, so each step is preceded by an explicit guard (rank <= (Limit - x) / M) that rejects the list with a printed message instead of silently truncating.
- **range**: Unrank's index into the output array needs a count guard against the fixed capacity, which a while loop in a procedure can supply with an explicit check that stops with a visible capacity message.
- **termination**: The unrank while loop is inside a procedure so no termination check is generated, and it is also bounded by the capacity guard.
- **length**: Building output lines of computed length in a bounded buffer needs explicit capacity guards before each append.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each demonstrated list, its rank and the recovered list, plus unrank of 0 to 10.

Assessed on 2026-10-15 against page revision 414268 of the [task](https://rosettacode.org/wiki/Index_finite_lists_of_positive_integers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
