# Machine code

**Excluded from Silver: unsafe operations, OS services.** Excluded: the task requires writing machine-code opcodes into memory and executing them. That needs unchecked address-to-subprogram conversion, foreign calls to allocate executable memory, and running unverified machine code, all of which break the Oracle's ban on unsafe constructs.

## Language surface beyond today's Silver

Integers, arrays, access types and subprograms.

## Oracle conflicts

- **unsafe operations**: The task's central requirement is to poke raw opcode bytes into memory and execute them. That means turning an address into a subprogram access (an unchecked conversion), allocating executable memory through foreign calls such as mmap, and running machine code that cannot be verified. SPARK excludes all of this, so no future Silver can admit it.

## External effects

- **console output** (allowed): Prints the result (19) returned by the machine code.
- **OS services** (not allowed): Needs executable memory from the operating system, such as mmap with PROT_EXEC, then munmap to clean it up.

Assessed on 2026-10-15 against page revision 399053 of the [task](https://rosettacode.org/wiki/Machine_code) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
