# Sort a list of object identifiers

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed array bounds, a capped field value and guards placed directly before each use, with while loops confined to procedures, but the loop-carried parsing accumulators need carefully shaped guards.

Position 1128 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the six OIDs as a constant array of records holding a fixed-capacity String buffer (capacity 40) and a length; a parse procedure converts each into an array of up to 16 bounded Natural fields plus a count, rejecting malformed or overlong input with a visible outcome. Sort an index array by insertion sort in a procedure, using a Boolean comparison function that walks the fields lexicographically with a for loop over the shorter count (shorter prefix sorts first), then print each OID's slice with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: The field accumulator value*10+digit is loop-carried, so a guard rejecting the OID when value exceeds a declared cap (for example 10_000_000) is placed just before each update, with the rejection as a specified outcome.
- **index**: Field counts and character positions are loop-carried, so each write to the fields array is guarded by a count below the fixed maximum, and the digit scan stays within the stored length via loop conditions.
- **termination**: The parsing scan uses a while loop, which is placed in a procedure (no termination check) and the sort uses bounded for loops, so no variant is needed.
- **range**: Character'Pos(c) - Character'Pos('0') is computed only after a guard that c lies between '0' and '9', so the digit range is established by the condition.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, text parsing, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The sorted OIDs are printed one per line with Put_Line.

Assessed on 2026-10-15 against page revision 414483 of the [task](https://rosettacode.org/wiki/Sort_a_list_of_object_identifiers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
