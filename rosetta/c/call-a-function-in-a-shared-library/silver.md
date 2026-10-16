# Call a function in a shared library

**Excluded from Silver: unsafe operations, OS services.** Excluded: the task requires loading a shared library at run time and calling a function in it through its address at the ABI level. That needs foreign calls and an unchecked Address-to-subprogram conversion, which SPARK and the Oracle rules exclude, and no admitted library operation could give it a specified, provable behavior.

## Language surface recorded by this assessment

Access types and subprograms.

## Oracle conflicts

- **unsafe operations**: The task's whole point is to load a shared library at run time and call one of its functions at the ABI level. That means a foreign-language call through an entry-point address that is only known at run time, which in Ada needs pragma Import or Convention and an unchecked conversion from System.Address to an access-to-subprogram. Rule 8 never allows this, and rule 6 rules out an admitted library operation for it, because an arbitrary foreign function's behavior cannot be specified.

## External effects

- **OS services** (not allowed): Uses the operating system's dynamic loader (dlopen/dlsym or LoadLibrary/GetProcAddress) to load a library and look up a symbol at run time.
- **console output** (allowed): Prints the result of the call, or the result of the internal fallback when the library is missing.

Assessed on 2026-10-15 against page revision 414101 of the [task](https://rosettacode.org/wiki/Call_a_function_in_a_shared_library) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
