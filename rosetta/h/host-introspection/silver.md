# Host introspection

**Excluded from Silver: environment.** Included. The task only prints two host properties, and Ada exposes both as compile-time constants in package System (Word_Size and Default_Bit_Order). SPARK allows reading these constants, and doing so needs no run-time introspection, unsafe code or annotations.

## Language surface recorded by this assessment

Integers, enumerations and packages.

## External effects

- **console output** (allowed): Prints the word size and the endianness.
- **environment** (not allowed): Needs system information about the host: its word size and byte order. Ada gets these from the static constants System.Word_Size and System.Default_Bit_Order, so Silver would have to admit those as specified platform facts.

Assessed on 2026-10-15 against page revision 413195 of the [task](https://rosettacode.org/wiki/Host_introspection) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
