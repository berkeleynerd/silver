# Common list elements

**Candidate: proofs likely to discharge automatically.** Direct streaming needs no result buffer, dynamic String building or user procedure. Constant-array iteration supplies bounded component values, and all tests and output use the existing finite bodies. Independent expected output uses set intersection and first-list ordering. A no-match regression exercises both false flags and empty output. Scope and validation status are recorded in docs/boolean-objects.md and the linked assessment record.

Position 67 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The driver samples/rosetta_common_list_elements.adb embeds exactly the task lists (2,5,1,3,8,9,4,6), (3,5,6,2,9,8,4) and (1,3,7,6,9) as constant arrays with component subtype 1..9. For each first-list element, nested foreach loops compute two Boolean membership flags. Their eager conjunction selects common elements. A separate Printed flag controls commas while Put streams a bracketed list in first-list order: 3,9,6, the same set as the task example 3,6,9. About 35 lines.

## Language surface recorded by this assessment

Scalar Boolean objects and expressions, named Integer subtypes and bounded components, fixed-size Integer arrays, constant Integer-array iteration, Integer image and Put without a newline.

## External effects

- **console output** (allowed): Prints the common elements as a bracketed list on standard output.

Initially assessed on 2026-10-15 against page revision 406865 of the [task](https://rosettacode.org/wiki/Common_list_elements) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-30 by Codex through targeted source review; see the [review record](../../../rosetta/assessment-boolean-objects-20261030.md).
