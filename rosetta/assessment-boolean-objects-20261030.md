# Boolean scalar driver reconciliation

Prepared source reconciliation on 2026-10-30 for
[#291](https://github.com/berkeleynerd/silver/issues/291). Complete assurance,
native validation and delivery remain pending. This record does not promote
the `scalar-boolean-objects` identifier to supported. The
[capability record](../docs/boolean-objects.md) records the authorization and
remaining completion requirements.

The bounded subthread selected GPT-6.1 Sol / Extra High through explicit spawn
controls. Runtime settings, whole-round elapsed time and token/cost measurements
are not independently exposed. Inputs were feature base `2b06103217`, the three
cached task descriptions and prior assessments, the selected scope and native
grammar briefing, and the prepared sample, manifest, language and catalogue
changes in this branch. This static reconciliation is separate from independent
review, native proof and Lean/source assurance.

**Sequence of primes by trial division**, task revision 413905, permits a bounded
sequence. The [driver](../samples/rosetta_sequence_of_primes_by_trial_division.adb)
uses the range 2 through 100 and tests every divisor from 2 through the candidate
minus one. A Boolean flag starts true and is cleared on exact divisibility.
For candidate 2 the inner loop is empty, so 2 is included. Trial division is the
actual executable algorithm; no precomputed prime list supplies its result.
The 25 expected prime lines in the manifest are independently derived by marking
composite multiples, with Ada Integer Image's leading spaces.

**Square but not cube**, task revision 415318, requires the first 30 positive
squares that are not cubes. The
[driver](../samples/rosetta_square_but_not_cube.adb) scans square roots 1 through
40 and cube roots 1 through 13. The cube range covers all squares through 1600.
A Boolean flag records equality with a cube; a directly guarded counter limits
output to the first 30 qualifying squares. They run from 4 through 1089. An
independent square/cube set difference derives the manifest's expected bytes.
The optional extra display of numbers that are both squares and cubes is omitted.

**Common list elements**, draft task revision 406865, supplies exactly the lists
`[2,5,1,3,8,9,4,6]`, `[3,5,6,2,9,8,4]` and `[1,3,7,6,9]`. The
[driver](../samples/rosetta_common_list_elements.adb) retains those data and uses
constant-array iteration with component subtype `1..9`. Two Boolean membership
flags decide whether to print the current first-list element; a third flag
controls commas. It streams `[ 3, 9, 6]`, the task's set `{3,6,9}` in first-list
order. The revised approach needs no dynamic String buffer, result array or
user procedure. Independent set intersection derives the expected result.
A regression variant replaces the third list with five sevens and expects
`[]`, exercising the no-match and separator boundary. Another variant isolates
prime candidate 2 to exercise the empty inner loop.

Only these three assessments are revised. Their original assessment date,
revision, model and effort fields remain historical; new review metadata
identifies this prepared reconciliation. Their surfaces now use the precise
`scalar-boolean-objects` fragment and the existing Integer/array fragments.
Broad `booleans` retains Boolean-valued functions and is not promoted. General
logical-operator or Boolean-flag stages are not completed by these mappings.
No other task's algorithm is reclassified by this source review.

The sample manifest and new catalogue entries explicitly retain
`pending_complete_assurance_and_delivery`. The assessor's current-language
description likewise distinguishes the pending extension. Final delivery must
remove stale pending claims, promote only the precisely covered identifier,
re-render generated pages and update stage bookkeeping against the actual
validation and independent review evidence. Static output derivation and
rendering alone establish no native admission, compilation, execution or
universal assurance claim.

Prepared-round checks: the independent expected-output oracle and all three
Rosetta rendering tests pass; Python fixtures parse; decoded catalogue producer
strings match both JSON construct and composition records; `git diff --check`
passes. `python3 rosetta/refresh.py --render` renders all 1,782 cached tasks,
retaining 53 stage-1 assessments and 1,576 candidates, now across 45 stages.
The three explicitly selected drivers occupy the pending scalar Boolean stage
37; the owner-selected milestone is separate from that generated order.
This subthread has run no native compiler or Lean validation. The lead retains
responsibility for integrating such evidence and final support promotion.
