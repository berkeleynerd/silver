# Monads/Writer monad

**Candidate: proofs plausibly discharge automatically.** The task needs only a bounded record, simple non-recursive functions, one Sqrt and bounded text appends, so every check follows from constant inputs and capacity guards; float formatting and Sqrt preconditions need careful range guards, hence plausible rather than likely.

Position 993 in the [progression](../../../progression.md#stage-16), in stage 16.

## Approach

A record holds a Float value plus a fixed 256-character log buffer and a length in 0..256; unit, root, addOne and half are non-recursive functions (with a bind that applies a step and appends a line) that return new records, and each log append is guarded by a remaining-capacity check that sets a visible overflow flag. Main composes unit(5.0), root, addOne, half and prints the golden ratio and the log lines through Put_Line, using a bounded float-to-text formatter. About 90 lines.

## Proof obligations to watch

- **floating point**: Sqrt needs a non-negative argument and the value must stay finite; the only input is the constant 5.0 and the steps are Sqrt, +1 and /2, so a guard on value >= 0.0 and a bounded range just before Sqrt lets the provers discharge it.
- **range**: Float-to-text formatting needs a bounded digit count and bounded magnitude, which a guard on the value range before conversion can supply.
- **length**: Each log append checks the remaining buffer capacity before copying, with a specified overflow outcome rather than silent truncation.
- **initialization**: The record's log buffer must be fully initialized by an aggregate in unit so flow analysis accepts later copies.

## Language surface recorded by this assessment

Floating point, floating-point images, records, string building, string indexing, ranged subtypes, integers, functions, procedures, arrays, for loops, Boolean objects and characters.

## External effects

- **console output** (allowed): Prints the golden ratio value and the multi-line log of function applications.

Assessed on 2026-10-15 against page revision 413133 of the [task](https://rosettacode.org/wiki/Monads/Writer_monad) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
