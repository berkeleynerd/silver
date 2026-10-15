# Undefined values

**Excluded from Silver: other, run-time error.** The task asks a program to exercise the language's notion of an undefined value, which in Ada means reading uninitialized or invalid scalars and testing them with 'Valid. SPARK Bronze flow analysis rules out reading uninitialized data, and producing an invalid value needs a configuration pragma or unchecked conversion, so no Silver program can do this.

## Language surface beyond today's Silver

Floating point and enumerations.

## Oracle conflicts

- **other**: Exercising Ada's undefined-value mechanism means creating and reading a variable whose value is undefined (uninitialized or invalid) and testing it with 'Valid. SPARK's Bronze level (initialization and data flow), which the Oracle requires every program to pass, rejects any read of an uninitialized variable, so a variable with an undefined value can never be observed.
- **run-time error**: In Ada, reading an uninitialized scalar is a bounded error. Getting an invalid value that 'Valid can detect needs a configuration pragma (Normalize_Scalars or Initialize_Scalars), Unchecked_Conversion, or invalid external data. The task asks for this undefined state to be observed, so it requires observing an erroneous or bounded-error condition.

## External effects

- **console output** (allowed): Prints whether each variable is valid or undefined, and its value once it is assigned.

Assessed on 2026-10-15 against page revision 415327 of the [task](https://rosettacode.org/wiki/Undefined_values) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
