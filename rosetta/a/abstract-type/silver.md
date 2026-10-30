# Abstract type

**Candidate: proofs likely to discharge automatically.** The task only needs declarations of abstract and interface types and a few dispatching calls with no loops, recursion or dynamic memory, so every check is a routine range check on a bounded counter or needs none.

Position 1547 in the [progression](../../progression.md#stage-33), in stage 33.

## Approach

A package declares a limited interface with an abstract Describe procedure, an abstract tagged record type with a concrete Counter component and a concrete Increment operation plus an abstract Process operation, and a concrete derived type that implements both. Main creates one object of the concrete type and calls its operations through a class-wide parameter so dispatching is shown, with all values being small bounded integers and no loops, access types or recursion. About 45 lines.

## Language surface recorded by this assessment

Packages, tagged types, procedures, records, integers and functions.

## External effects

- **console output** (allowed): The program prints a line from each concrete implementation to show the abstract operations were dispatched.

Assessed on 2026-10-15 against page revision 414050 of the [task](https://rosettacode.org/wiki/Abstract_type) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
