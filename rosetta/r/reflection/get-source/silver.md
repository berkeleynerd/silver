# Reflection/Get source

**Excluded from Silver: outside SPARK.** Excluded: the task asks a program to report where its own module or function is defined, or to return that source, which is reflection on program structure. Standard Ada/SPARK cannot express this; only GNAT's non-standard Source_Info intrinsics come close.

## Language surface recorded by this assessment

String operations and subprograms.

## Oracle conflicts

- **outside SPARK**: The task requires reflection: the program has to look up, at run time, the source text or the file path and line number where one of its own entities (module, function, method) is defined. Standard Ada/SPARK cannot inspect its own program structure. The only route is the GNAT-specific intrinsic package GNAT.Source_Info, which is a compiler extension rather than ordinary SPARK. Printing a hand-written file name and line number would not be faithful, because it does not look anything up.

## External effects

- **console output** (allowed): Prints the source location (file path and line number) or the source text of the named entity.

Assessed on 2026-10-15 against page revision 411098 of the [task](https://rosettacode.org/wiki/Reflection/Get_source) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
