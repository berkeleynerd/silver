# Address of a variable

**Excluded from Silver: unsafe operations, hardware.** The task asks a program to get and set the memory address of a variable. That needs System.Address, address clauses at absolute locations or overlays, and address-to-integer conversion. These are unsafe, aliasing constructs that the Oracle never admits, so the sample is excluded.

## Language surface recorded by this assessment

Integers.

## Oracle conflicts

- **unsafe operations**: The task's whole point is to manipulate machine addresses. Getting a variable's address means taking System.Address and turning it into something observable (address-to-integer conversion). Setting a variable's address means an address clause, either at an absolute hex location such as 16#A100# or overlaid on another variable. That is address arithmetic plus unrestricted aliasing or overlays, which rule 8 excludes and which cannot be proved safe without assumptions about the environment.

## External effects

- **console output** (allowed): Printing the address that was obtained, to show it worked.
- **hardware** (not allowed): Placing a variable at a fixed absolute memory address depends on the machine's memory layout.

Assessed on 2026-10-15 against page revision 413316 of the [task](https://rosettacode.org/wiki/Address_of_a_variable) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
