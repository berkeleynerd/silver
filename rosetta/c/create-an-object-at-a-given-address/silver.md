# Create an object at a given address

**Excluded from Silver: unsafe operations.** Excluded. The task requires placing an integer at the address of another object and printing that address, which needs address operations and overlay aliasing. Silver's Oracle bans unsafe constructs such as address arithmetic and unrestricted aliasing.

## Language surface beyond today's Silver

Integers and packages.

## Oracle conflicts

- **unsafe operations**: The task's whole point is to take a machine address, print it, and put a second object at that address so the two names refer to the same memory. That needs address arithmetic and conversion ('Address, System.Storage_Elements.To_Integer) plus an address clause that makes two objects share storage. That is the unrestricted aliasing and address manipulation the Oracle excludes.

## External effects

- **console output** (allowed): Prints the object's address and the aliased object's value before and after the original is changed.

Assessed on 2026-10-15 against page revision 412075 of the [task](https://rosettacode.org/wiki/Create_an_object_at_a_given_address) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
