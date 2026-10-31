# Array declaration equality diagnostic

Issue #291, 2026-10-30. Selected native worker GPT-6 Astra / Extra High;
runtime model confirmation and token/cost measurements are unavailable.

The preserved pre-xor unit run `20261030T094353-9ea6896732dc` has one completed
unresolved primitive goal in `silver_output_profile__array_declaration_at`:
`def'vc.247`, with all recorded solvers timing out, and its transformed
`def'vc.247.0`. The enclosing root is also unproved; those parent nodes are
not additional source obligations. Other unit functions are still running.

Reading the existing Why3 session preorder and its version-6 shape table maps
`.247` checksum `1d55f0dbe64d5a32bb5eb6242767c139` to shape 457: equality between
`array_declaration_at`'s result and `array_declaration_model`. After introducing
premises, shape 456 is exactly that final equality. It corresponds to the
Static postcondition at frozen source line 1557. The preceding runtime
state-validity and cursor-progress goals are proved. No solver was rerun to
obtain this mapping. A copied original gnat-json was also parsed and printed
with the existing generic Why3 executable, with no prover selected.

The first bounded repair hypothesis is to expose the existing verified
`Same_Parser_State` logical equality before the unchanged whole-record equality
in the Static postcondition. This strengthens the checked ghost contract and
adds no runtime operation. The helper includes all fixed-array extents and
Boolean metadata. It should let the splitter transport the equality through
the array initializer/model call without solving the entire record identity in
one large goal. This is a hypothesis until the focused check passes; no proof
budget, accepted input, endpoint domain or obligation is weakened.

The next experiment is one focused `Array_Declaration_At` check in the separate
one-worker native context, preserving the original two-worker unit run and its
frozen source/cache. Complete validation remains the lead's responsibility.

## First experiment and revised hypothesis

Run `20261030T105723-c229d7265935` completed in 1054.437 s on native Linux
with one worker and the original level-2, 30-second, cvc5/z3/altergo settings.
The native tool returned 0, but the managed runner correctly failed the run:
33 of 34 proof checks passed, with two additional flow/termination checks.
The unresolved check is exactly
`silver_output_profile.adb:1559:19:VC_POSTCONDITION`. Its final Why3 goal
`def'vc.262` and transformed `.262.0` time out. The preceding `.261` goal is
proved by z3. Compressed reports, original gnat-json, complete Why3 session,
and exact source hashes are retained in `native-repair/`.

A no-prover print of the generated Why3 task confirms that the added logical
record equality and original Boolean record equality remain siblings of the
final conjunction. Thus the first experiment did not establish the desired
proof cut. It is not evidence of an identified runtime-state validity failure.
The integration checkout was restored byte-for-byte from its source backup
immediately after the run; its tracked status is clean.

The next bounded hypothesis keeps the original Static equality unchanged and
places a checked `Same_Parser_State` assertion before returning the already
computed result. The native expression becomes a local constant initializer;
the expression itself is unchanged. This introduces an intermediate proof fact
without changing accepted source or equality semantics. Its possible temporary
storage effect still requires normal native validation. The source bridge
consumes this wrapper's implementation header and exact Static contract; the
model and Add_Array_Binding expression translations remain unchanged. The lead
confirmed that interface on 2026-10-30 before this second experiment.

One focused check will test the revised hypothesis with the same strict proof
settings, reusing the retained cache while keeping the first experiment's
reports and the older unit run intact. No solver or obligation budget is relaxed.

## Additional unit-run diagnostic: string reader

While the original unit run remains active on frozen `828dd16e6e`, its completed
`Read_String_In_Flow` session has one unresolved primitive goal, `def'vc.75`
(with transformed `.75.0`). All recorded solvers timed out. Its shape checksum
`ae8b0062dc9d2c657a236bdbbe755525`, shape 102, is exactly the Static equality
between the returned expression result and `Expression_At` evaluated with
`Reading_Names`, Boolean integer hiding, initializer values, and elaboration
mode. It maps to frozen source line 2184. The cursor-progress check is proved.
The native wrapper retains a local scalar environment copy `Overlay`; its
postcondition instead refers to the function result `Reading_Names` directly.
The task also expands the executable expression reader into its tail call.

This is not yet a demonstrated bug in the Boolean admission logic. The next
specific question is whether a checked logical-array identity assertion for
`Overlay.Items` and `Reading_Names(Context,Facts).Items`, plus their checked count
identity, gives the existing expression call the missing congruence fact. The
existing `Same_Parser_Scalar_Items` helper includes fixed array extents and has
its own checked Logical_Equal annotation. No string-reader repair or solver
rerun has yet been made; first finish the active array-declaration cut experiment.
The completed session, shapes, gnat-json, and frozen source hash are retained in
`native-repair/read-string-in-flow/`; they do not claim a successful unit run.

## Checked array-declaration cut result

Run `20261030T112107-09c976deac55` passed all 37 focused checks with the same
strict proof settings in 607.875 s. The intermediate
logical equality assertion and the unchanged final Static equality both proved.
The exact captured source hashes, original proof reports, complete Why3 session,
shapes, gnat-json, native log and managed events are retained in
`native-repair/array-cut/`. The shared checkout's 131 source files were then
restored byte-for-byte from the original backup. This is a focused repair result;
complete unit validation and the separate string-reader equality remain pending.

## First string-reader experiment

After the array cut passed, the next candidate adds a checked Static assertion
that the local Overlay count and complete fixed-array items agree logically with
`Reading_Names(Context,Facts)`. The existing Same_Parser_Scalar_Items helper
provides the already checked logical-array identity. The executable return
expression and original Static postcondition are unchanged; these assertions
introduce no runtime work. Source review confirmed that the FlowReaders bridge
uses the exact Static contract and implementation header, both unchanged.
One focused check of Read_String_In_Flow will test this congruence hypothesis
under the same native prover settings, after retaining its existing failed goal.

## Overlay experiment result and next diagnosis

Run `20261030T113626-d7b8aad7d3c5` failed after 535.146 s.
The new overlay count/items assertion proved; the sole remaining primitive goal
is still the final Static result/Expression_At equality (`def'vc.81` and `.81.0`,
source line 2190). Thus overlay logical identity alone is insufficient. The
returned Expression_Result is a flat six-field record, while Expression_At's
checked contract equates it to the recursive expression-tail model. The next
specific hypothesis is to split the final expression-result identity through a
checked Logical_Equal helper over those six fields and assert it before return,
as the successful array declaration repair does for Parser_State. The helper's
own annotation must be proved separately or in the same focused region; it is
not an unchecked axiom. The original exact wrapper postcondition stays unchanged.
The failed overlay-only assertion will be removed from the new candidate.

The failed experiment's exact source hashes and complete proof artifacts are in
`native-repair/string-overlay/`. The shared root source was restored exactly after
this run. No duplicate run or relaxed prover budget was used.

## Result-cut experiment and literal-array diagnosis

Run `20261030T115004-8f4e263b7fc5` finished naturally with a managed failure
after 1823.034 s. The six-field `Same_Expression_Result` helper's annotation
proved (all three helper session goals). The wrapper has two unresolved primitive
goals: `.73`, the new checked result assertion at line 2219, and `.110`, the
original exact Static postcondition at line 2200. Their transformed children
`.73.0` and `.110.0` also time out. All other selected checks passed. Unattempted
goals from unselected functions in this region-limited run are not counted as
additional failures. The run was not interrupted.

The retained final live SMT task and version-6 shape table narrow the issue to
otherwise-identical calls containing independently generated String arrays for
`Name_Is(..., "integer")`. The executable call, assertion and final postcondition
use distinct literal objects; the retained target shows the assertion's object
`temp___String_Literal_20397` versus the postcondition's
`temp___String_Literal_8314`. Both specify the same seven characters, but their
whole-array identities are distinct. This is a prover congruence hypothesis, not
a demonstrated difference in executable language semantics.

The next candidate removes the unsuccessful result-cut scaffold and changes
only the two original reader occurrences of `"integer"` to the existing package
constant `Integer_Type_Word`, whose declaration is exactly
`constant String := "integer"`. The original wrapper body, exact result equality,
precondition domain and native proof settings are retained. The source subthread
owns the matching FlowReaders render-token and exact constant-declaration check;
this adds no helper-meaning premise. The lead approved this bounded repair.

Complete reports, selected sessions/shapes/gnat-json, captured source hashes,
failed candidate source, live SMT task and managed logs are in
`native-repair/string-result-cut/`. All 131 shared root source files were restored
byte-for-byte before preparing the next experiment. The next check selects the
original wrapper directly with `--limit-subp`, avoiding the additional
unselected-function processing observed with `--limit-region`.

## Minimal string-reader repair result

Run `20261030T122217-a1313f11b288` passed all 18 selected checks in 65.257 s
with the original strict native prover settings. The two uses of the existing
`Integer_Type_Word` constant are the entire reader change; no result helper,
local result record or additional assertion remains. This supports the
literal-identity diagnosis while preserving the exact result contract and native
domain. The change from region to subprogram selection also reduced unrelated
processing, so the elapsed-time difference does not isolate either effect.
The passing artifacts and exact candidate are in `native-repair/string-word/`.
The shared checkout's 131 source files were again restored exactly.

## Additional unit-run diagnostic: primary reader

The preserved pre-xor unit run has now completed `Read_Condition_Into` with all
480 Why3 session goals proved. `Read_Primary_Into` completed with 403 goals and
one unresolved primitive `.355`, plus transformed `.355.0` and its enclosing
root. Shape 420, checksum `64c9bfecea7b29157124e3d1f4254f6a`, is the exact
`Result = Primary_Model` equality after the input-validity branch updates
`When_True.Path` and `When_False.Path`. The exact assertion-versus-postcondition
location is still being mapped; neither a broader runtime-state defect nor a
complete unit result is claimed.

Both the native and model calls in this branch contain a separate
`Name_Is(..., "input_is_valid")` literal. The specific next question is whether
that creates the same literal identity barrier as the now-repaired string
reader. The completed session, shapes, gnat-json and frozen source identity are
retained in `native-repair/read-primary-into/`. No primary repair or rerun has yet
been made. The old unit source and cache remain unchanged.

## Primary-reader literal diagnosis and bounded experiment

A no-prover print of the original annotated gnat-json identifies the failing
branch assertion as `GP_Check:1472:VC_ASSERT:silver_output_profile.adb:2880:35`.
The native call uses `temp___String_Literal_21591`; the expanded Primary_Model
uses `temp___String_Literal_10182`. Their declarations specify the same 14
characters, `input_is_valid`, as separate arrays. The complete printed task is
retained in `native-repair/read-primary-into/no-prover-task.txt.gz`; no solver
was invoked to inspect it.

The next bounded hypothesis adds a shared `Validity_Call_Word` String constant
with that exact value, then substitutes its name at only the model and native
input-validity mask checks. The existing result assertion, exact contract,
full native precondition and strict prover settings stay intact. There is no
additional assumed helper fact. The source subthread owns explicit typed-word
rendering and an exact constant-declaration check, rather than changing the
generic literal renderer to disguise the new identifier spelling. The lead
approved the bounded repair after reviewing this diagnosis. One focused primary
reader check will test it; final source correspondence and complete native
validation remain outstanding.

## Primary-reader constant repair result

Run `20261030T123417-c0207905bf52` passed all 79 selected checks in
2162.692 s under the unchanged strict native settings. Both the
previously unresolved input-validity assertion and the full postcondition proved.
The three-line source delta consists only of the fixed `Validity_Call_Word`
declaration and the two explicit substitutions. The complete passing artifacts
and exact candidate are retained in `native-repair/primary-word/`. All 131 shared
root source files were restored exactly afterward. The source subthread's
explicit word-node and constant-declaration checks passed its fresh 37,361-
declaration audit in run `20261030T125139-6833062de0b7`; authoritative actual-source
extraction remains part of the lead's final checkpoint.

The preserved older pre-xor unit also completed `Read_Relation_Into` with all 711
Why3 goals proved. It remains active; these focused repairs do not claim a
complete final-source native proof. Final catalogue changes occurred in the
separate native branch during this run and did not alter its frozen inputs.
