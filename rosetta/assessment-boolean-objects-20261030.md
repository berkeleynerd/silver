# Boolean scalar driver reconciliation

Delivery metadata prepared on 2026-10-30 for
[#291](https://github.com/berkeleynerd/silver/issues/291), in an unmerged
Rosetta-only patch. Its `scalar-boolean-objects` support promotion is contingent
on the complete assurance, native validation and independent review checkpoint.
The patch must remain separate until the lead integrates that evidence and
synchronizes the capability record, language, catalogue and samples. This static
record claims no completed native validation or universal assurance. The
[capability record](../docs/boolean-objects.md) records the authorization and
remaining completion requirements.

The source reconciliation below and its recorded inputs/settings are historical
prepared-review provenance. The delivery round is recorded separately below.

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
revision, model and effort fields remain historical; current review metadata
identifies the delivery-metadata reconciliation. Their surfaces now use the precise
`scalar-boolean-objects` fragment and the existing Integer/array fragments.
Broad `booleans` retains Boolean-valued functions and is not promoted. General
logical-operator or Boolean-flag stages are not completed by these mappings.
No other task's algorithm is reclassified by this source review.

The precise fragment additionally prohibits xor in either operand of xor, while
permitting independent xor expressions. This avoids repeated formula
multiplication in the pinned proof producer; it is not an Ada restriction. The
three driver programs need no xor, so this restriction changes no mapping.

The original prepared review used these existing metadata fields for all three
tasks: date `2026-10-30`, record
`../rosetta/assessment-boolean-objects-20261030.md`, model `gpt-6.1-sol`, effort
`xhigh`, setting evidence “Selected setting through bounded subthread controls;
runtime model and effort not independently exposed”, and method “Prepared
source/task/scope reconciliation and independent expected-output derivation; no
native or Lean runner; complete assurance and delivery pending”. Updating the
current `review` fields does not reinterpret that review as completed assurance.

Historical prepared-round checks: the independent expected-output oracle and
all three Rosetta rendering tests passed; Python fixtures parsed; decoded
catalogue producer strings matched both JSON construct and composition records;
`git diff --check` passed. `python3 rosetta/refresh.py --render` rendered all 1,782
cached tasks, retaining 53 stage-1 assessments and 1,576 candidates across 45
stages. The three selected drivers occupied pending scalar Boolean stage 37.
The owner-selected milestone is separate from that generated order.

## Contingent delivery round

Inputs: feature commit `eb1015c8e3`, its prepared source/task reconciliation,
the inherited xor restriction and this Rosetta-only patch. The bounded delivery
subthread selected GPT-6.1 Sol / High through explicit spawn controls; runtime
model/effort confirmation and token/cost measurements are unavailable. Its
intended result is a reviewable delivery patch, not completion of #291.

Only `scalar-boolean-objects` is added to `coverage.json`'s supported list.
Broad `booleans` still includes Boolean-valued functions; logical-operator and
Boolean-flag stages are not promoted. The current assessor description states
the precise fragment, conservative stored flags, eager and short-circuit safety,
Ada name visibility, unchanged budgets and xor restriction. Assessment summaries
now describe the actual drivers without treating this metadata preparation as
native evidence. No new metadata schema is introduced.

At this checkpoint the three sample `delivery_status` fields remain
`pending_complete_assurance_and_delivery` in `samples/manifest.json`. There are
no matching pending-delivery flags in `catalogue/silver.json` or its native
producer `src/silver_catalogue.adb` at the named input. The lead owns those files
and must synchronize actual delivery status before the final source checkpoint;
this Rosetta patch changes none of them. Prior statements that new catalogue
entries themselves retained that pending marker were inaccurate.

Static output derivation and rendering establish no native admission,
compilation, execution or universal assurance claim. The lead retains
responsibility for complete evidence, independent review, capability status and
stage-issue bookkeeping before integrating this support promotion.

Delivery-round validation on Linux x86_64: `python3 rosetta/refresh.py --render`
rendered all 1,782 cached tasks. The three Rosetta tests plus the independent
Boolean-driver expected-output test passed (4 tests in 46.620 seconds).
`git diff --check` passed. These are compiler-independent checks; this subthread
ran no native or Lean validation and made no GitHub writes.

| Progression measure | Prepared base | Contingent delivery patch |
| --- | --- | --- |
| Candidates | 1,576 | 1,576 |
| Stages | 45 | 44 |
| Stage-1 assessments | 53 | 56 |
| Unlikely / excluded / design-pending assessments | 2 / 203 / 1 | 2 / 203 / 1 |

All three drivers move from stage 37 to stage 1. Earlier construct stages retain
their numbers; old stages 38 through 45 become 37 through 44, respectively:
fixed point, Integer object Size clauses, static Integer types, Integer object
Size reads, fixed String replacement, Unicode identifiers, assignment-target
names, and variant records. Thirteen tasks change stage; the renderer also
updates global positions on other pages. Its generated-page churn is expected.

At integration, update existing open and closed stage issue fields against the
new construct mapping. A dedicated issue covering only `scalar-boolean-objects`
can carry Stage 1 and close once its delivery requirements are complete. Keep
broad Boolean, logical-operator and Boolean-flag issues open for their remaining
forms. #291 remains the owner-selected work package; its closure requires the
complete checkpoint and delivery, not this re-render. No new stage issue or
next-stage authorization is implied by this patch.
