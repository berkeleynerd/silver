# Generic swap

**Candidate: proofs likely to discharge automatically.** The only checks are initialization and data flow on the in out parameters and a temporary of the same definite type, plus integer 'Image output, so every instance proves routinely with no loops, arithmetic or guards.

Position 1517 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

A generic procedure Generic_Swap with a formal private type and two in out parameters exchanges them through a constant temporary. Main instantiates it for Integer and for a fixed-length String subtype, initializes two variables of each, and prints them before and after each swap using 'Image for the integers and Put_Line for the strings. About 35 lines.

## Language surface recorded by this assessment

Generics, procedures, integers and 'Image of scalars.

## External effects

- **console output** (allowed): The program prints the two variables of each type before and after swapping with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412818 of the [task](https://rosettacode.org/wiki/Generic_swap) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
