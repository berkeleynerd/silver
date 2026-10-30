# Null object

**Candidate: proofs likely to discharge automatically.** In Ada, null exists only for access values, so the program needs an access type declaration, but with no allocation or dereference the only checks are initialization and the leak check on a known-null value, which discharge trivially.

Position 1563 in the [progression](../../progression.md#stage-36), in stage 36, which adds access types.

## Approach

Main declares a pool-specific access type to Integer and a variable of that type initialized to null, without ever allocating. An if statement compares the variable with null and prints "object is null", with an else branch printing "object is not null". About 12 lines.

## Proof obligations to watch

- **heap**: The pool-specific access variable is never allocated, so the ownership memory-leak check at scope exit discharges because the value is known to be null.

## Language surface recorded by this assessment

Access types.

## External effects

- **console output** (allowed): Prints whether the object equals null with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412942 of the [task](https://rosettacode.org/wiki/Null_object) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
