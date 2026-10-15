# Use another language to call a function

**Excluded from Silver: unsafe operations, other.** Excluded: the task's whole point is to export a C-convention Query function that writes through a raw char* and a size_t* passed in by a C main program. That needs foreign-language interop and unchecked pointer access, which the Oracle's rules (no foreign-language calls, no unrestricted aliasing) rule out for good.

## Language surface beyond today's Silver

Arrays, string operations, subprograms, packages and access types.

## Oracle conflicts

- **unsafe operations**: The task requires a Query function that a C program links against and calls. The function must use C convention and be exported (Export/Convention C) and take a raw char* buffer and a size_t* by pointer. That is foreign-language interop with unchecked C pointers, and the C caller, which is outside SPARK, controls the buffer's real size and aliasing. A program limited to SPARK's own checks could not prove it free of run-time errors.

## External effects

- **other** (not allowed): The Silver code has to be linked into a foreign C program and called from it through a C ABI entry point. The C main does the printing.

Assessed on 2026-10-15 against page revision 383787 of the [task](https://rosettacode.org/wiki/Use_another_language_to_call_a_function) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
