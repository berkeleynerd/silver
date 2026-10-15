# Call an object method

**Candidate: proofs likely to discharge automatically.** The program has only straight-line calls of procedures that print constant strings, so there are no run-time checks beyond initialization and flow, which discharge trivially. The only growth needed is Silver support for packages, tagged types and user procedures, and the task does not require dispatching or overriding.

Position 1557 in the [progression](../../progression.md#stage-35), in stage 35.

## Approach

Declare a package My_Class with a tagged null-record type Object, a static procedure Static with no parameters, and an instance procedure Primitive taking an Object, each printing a fixed string with Put_Line. Main declares one Object, calls My_Class.Static, then calls the instance method both as Primitive (Obj) and as Obj.Primitive. There are no loops, arithmetic or input, so there are no guards. About 25 lines.

## Language surface beyond today's Silver

Packages, tagged types, records and procedures.

## External effects

- **console output** (allowed): Each method prints a greeting line with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415470 of the [task](https://rosettacode.org/wiki/Call_an_object_method) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
