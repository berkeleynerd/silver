# Code segment unload

**Excluded from Silver: unsafe operations, outside SPARK, OS services.** The task asks a program to unload part of its own code from memory. In Ada/SPARK that can only be done through loader or OS calls that work on code addresses, which means foreign calls and address arithmetic that SPARK and the Oracle forbid. The task itself lets languages without this facility be omitted, so it should be excluded.

## Language surface recorded by this assessment

Access types.

## Oracle conflicts

- **unsafe operations**: Releasing part of the program's own code segment back to the memory manager needs the address of the code region and an OS or loader call (for example unloading a shared library or unmapping pages). That means foreign-language calls and address manipulation, which Rule 8 and the unsafe-construct restrictions exclude.
- **outside SPARK**: Ada/SPARK has no construct for a program to unload or free its own code at run time. Code is not an object the language can deallocate, so this kind of introspection and manipulation of program structure cannot be expressed.

## External effects

- **OS services** (not allowed): Code memory can only be marked reusable through the operating system's loader or virtual-memory services, for example unloading a dynamic library or releasing pages.

Assessed on 2026-10-15 against page revision 361257 of the [task](https://rosettacode.org/wiki/Code_segment_unload) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
