# Singleton

**Candidate: proofs likely to discharge automatically.** The program only assigns and reads one default-initialized package-level record with no arithmetic, loops or indexing, so the only checks are initialization and data flow, and those discharge from the default initializer. The thread-safe variant is optional and is left out, so no tasking is needed.

Position 1458 in the [progression](../../progression.md#stage-27), in stage 27.

## Approach

A package Global_Singleton declares a private record type with a default-initialized Integer component, plus one package-level Instance of that type in its private part, so only one instance can exist. The procedure Set_Data and the function Get_Data are the only ways to reach it. Main calls Set_Data with embedded literals and prints Get_Data'Image through Silver_IO.Put_Line, and needs no arithmetic or guards. About 35 lines.

## Proof obligations to watch

- **other**: Without an Abstract_State aspect, flow analysis has to infer the generated Globals for the package-level Instance in the private part, which GNATprove does automatically for state that is default-initialized at elaboration.

## Language surface recorded by this assessment

Packages, records, integers, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Main prints the singleton's data before and after updating it through the package operations, showing that every call works on the one instance.

Assessed on 2026-10-15 against page revision 413229 of the [task](https://rosettacode.org/wiki/Singleton) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
