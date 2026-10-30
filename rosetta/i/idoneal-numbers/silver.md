# Idoneal numbers

**Candidate: proofs likely to discharge automatically.** Every check follows from the 1..1850 subtypes, the bounded products and the explicit guard before the array store, and all loops are for loops in a procedure, so no annotation is needed.

Position 1534 in the [progression](../../progression.md#stage-32), in stage 32.

## Approach

Declare a subtype N_Range is Integer range 1 .. 1850 and a Boolean array Representable indexed by it, initialized to False. Nested for loops over a, b and c (each N_Range, with guards skipping unless a<b<c) compute s = a*b + b*c + a*c in Integer, and only when s <= 1850 set Representable (s) to True; then a final for loop prints every n whose flag is False via Put_Line of the Image text. All loops are plain for loops in the parameterless Main procedure, so no variants or invariants are needed. About 45 lines.

## Proof obligations to watch

- **overflow**: Products a*b and c*(a+b) are nonlinear, but a, b and c are subtypes of 1..1850 so the sum is at most about 10 million, well inside Integer, and the provers handle these bounded products.
- **index**: The Boolean marker array is indexed by the sum only after an explicit guard that the sum is at most 1850, so the index check follows from the guard just before the store.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, Put without a newline, string building and membership tests.

## External effects

- **console output** (allowed): Prints the 65 idoneal numbers, one per line or several per line, to standard output.

Assessed on 2026-10-15 against page revision 414265 of the [task](https://rosettacode.org/wiki/Idoneal_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
