# Multiplicative order

**Candidate: proofs plausibly discharge automatically.** All checks follow from range subtypes capping moduli at 10_000 and a bounded for loop with incremental modular multiplication, but nonlinear mod arithmetic and LCM overflow guards require careful shape, and no annotation is needed.

Position 256 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Embed the task's example pairs (element, modulus, and coprime factor lists) in small constant arrays with ranged subtypes capping moduli at 10_000. A procedure finds the order of a modulo m by a for loop from 1 to m that updates a residue incrementally with (acc * a) mod m and records the first hit with a found flag, printing a not-coprime message otherwise. A second procedure combines per-factor orders with a while-loop GCD in a procedure and a guarded LCM, then prints results via 'Image. About 90 lines.

## Proof obligations to watch

- **overflow**: Modular products (acc * a) stay below 10_000 * 10_000 because the moduli and residues are range-subtyped to at most 10_000, so they fit in Integer, but the provers must handle the nonlinear multiply and mod.
- **range**: The loop-carried residue is assigned the result of 'mod Modulus' into a subtype 0 .. 9_999, which follows from Modulus being at most 10_000 and positive.
- **overflow**: The LCM of per-factor orders is computed only after a guard that the product stays within a fixed cap, otherwise a visible 'too large' outcome is printed.
- **termination**: The GCD loop is a while loop, so it lives in a procedure (no termination check), while the order search uses a bounded for loop.
- **other**: An element not coprime to the modulus has no order, so the search loop ends without a hit and the program prints a specified 'no order' outcome rather than raising Program_Error.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each computed multiplicative order, or a not-coprime message, as a line of text.

Assessed on 2026-10-15 against page revision 413798 of the [task](https://rosettacode.org/wiki/Multiplicative_order) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
