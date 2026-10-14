# Equality, guards and branches

The owner authorized delivery of roadmap **5a–5c** on 2026-10-13, based on
`7fb1514199`, continuing autonomously through implementation, validation and
publication. All three milestones are required; completing 5a alone does not
complete this task. Milestone 5a is supported at its complete Linux checkpoint;
the coupled 5b/c extension remains in progress.

## Delivery sequence

1. **5a — complete:** nested String-equality conditionals, `elsif` and optional
   `else`, retaining the existing outer input guard and expression/source limits.
   Branches contain existing statement sequences. Retain exact source syntax in
   the model, including the distinction between `elsif` and a nested `if`.
2. **5b — in progress:** explicit predicate/Boolean grammar and integer-literal
   spellings, preserving Ada evaluation and lexical rules. Establish safe
   short-circuit evaluation, overflow-safe parsing and justified exclusions.
3. **5c — in progress with 5b:** path-sensitive expression/assignment checking,
   branch joins and generalized input-guard/Reject placement. Every invalid-input
   execution must retain the specified rejection/no-output behavior. `Reject`
   returns; it must never be treated as terminating later execution.

Each milestone includes source-decidable admission, complete modeled obligation
discharge, universal semantics, inhabited actual-source interpretation, native
SPARK verification and corresponding specification/catalogue/samples/tests.
Use focused proof lanes during development and stable complete checkpoints for
supported increments. Predicates and path analysis may share their final
checkpoint. Optional independent kernel replay and macOS proofs are not required;
GitHub Actions stays disabled. Preserve existing caches and all earlier evidence.

The path-analysis design can exploit the existing fixed bound shapes: every
object has a static length or the immutable selected-input length. Input-validity
and length facts remain stable across assignment. True String equality implies
equal lengths; false String equality does not imply unequal lengths. General
mutable byte-equality tracking is not required by this fragment.

## Stop conditions and recovery

Continue through ordinary implementation, resource tuning and proof failures.
Summon the operator only for a required Oracle amendment, conflicting owner
requirements, or missing external access/resources with no sound authorized
workaround. Do not suppress obligations, narrow existing admitted inputs or
declare partial work complete to avoid a failure.

`tmp/branches-active.json` records the baseline, evidence directory and isolated
proof lanes. The initial Linux sandbox has twelve CPUs and 31 GiB RAM, no swap;
the owner's larger physical-host memory is distinct. Preserve the warm canonical
proof cache, private/server sidecars, Lake metadata and the saved pre-task native
reports/compiler/Lean evidence. Input/model/source changes must be reviewed
together; source-pin regeneration alone is not correspondence.

The 5a checkpoint below is complete. This record and the
[roadmap](../roadmap.md#equality-guards-and-branches-increments) retain the coupled
5b/c work, including failures, actual input scope and remaining requirements.

## 5a development evidence (chronological)

Focused Linux checks now establish the recursive syntax, execution, obligation
folds, source-reading soundness, and immutable body-context preservation. Each
focused run includes a fresh axiom audit and retains only the standard three
foundations. These are partial checks; complete source correspondence and the
stable complete checkpoint remain required.

The native draft passed 21 focused test methods, including the new nested,
`elsif` and omitted-`else` cases and returning write/flush failures. Source-bound
probes admitted, proved, compiled and ran 210 nested `then` levels, 138 nested
`else` levels and 199 `elsif` arms. Recognition also passed with a 2 MiB stack;
4097-byte neighbours were rejected. Results, exact inputs and commands are under
the task evidence directory recorded by `tmp/branches-active.json`, in
`tests-5a/` and the initial feasibility directory’s
`native5a-recognition-boundaries/`. The compiler's isolated focused
SPARK run remains in progress; the native draft is not a supported checkpoint.

The unrun 5b/c test drafts are retained under that directory's `drafts/` so they
do not enter the 5a test-discovery scope. Restore them for the coupled predicate
and path-analysis implementation. Direct frontend probes in `integer-frontend/`
accept decimal and based zero literals with exponent 4096. Arbitrarily large
exponents can be rejected or expensive even when the mathematical value is zero.
The planned exponent limit therefore needs an explicit resource rationale; it
must not be described as an Ada universal-integer range.

## Coupled 5b/c implementation design

Use the existing fixed binding shapes and immutable selected-input length `d`.
Track a closed interval of possible lengths for valid inputs, and separately
track whether invalid inputs remain reachable and have definitely executed
`Reject`. Invalid inputs normalize to the empty input, hence `d = 0` on those
paths. Keep the categories separate so a later validity test can recover the
fact that an earlier invalid arm already rejected. `Reject` returns, sets sticky
failure, and supplies no validity fact.

Predicate checking produces true and false contexts. Check its operands in the
incoming context before using its result. For `and then`, check the right operand
under the left's true context; for `or else`, use the false context. Parentheses
are required when mixing logical operators according to Ada grammar. A true
String equality refines the affine length equation; its false result gives no
length inequality. Length comparisons are exact on fixed lengths and `d`.
Joined intervals cover both incoming paths; rejection is guaranteed only when
all reachable invalid paths have executed it. An omitted `else` contributes the
unchanged false context.

Check expression bounds at the greatest reachable length, and check fixed-bound
assignment equality over the reachable interval, using its endpoints. Facts
about lengths survive writes because assignment preserves each object's bounds.
Every reachable invalid-input output is rejected by admission, and every final
invalid-input path must have executed `Reject`. Prove these properties through
sequences and joins, then carry the same rules through source interpretation,
complete obligation coverage, runtime selection and report-policy selection.

One exploratory grammar-lane run compiled the range proofs but was correctly
rejected by the runner's input-drift check after an overlapping lane sync. It is
not validation evidence. A serialized repeat passed with a fresh audit. The
local lane helper now takes a nonblocking writer lock before synchronization.
Canonical proof artifacts and earlier evidence were unaffected.

The scalar scanner's final focused SPARK run proved all 685 checks. Its runtime
traversal caches each child result, avoiding repeated parsing of nested bodies;
small recursive frames share the immutable declaration context. Source-limit
then/else/elsif and later-nested shapes, flat null/assignment bodies and over-limit
neighbours pass at both 2 MiB and 8 MiB stack settings (`native-scalar-boundaries/`).
Recognition took 3–18 ms per probe. These are measured cases, not universal runtime
bounds. Earlier failed ghost-loop refinement attempts remain in the logs; the
final imperative bodies have independently checked Lean equations. Complete
native verification and source certificates have passed against stable Ada.
Predicate/path-fact foundations are being prepared in isolated drafts while the
5a correspondence proof is completed; 5b/c support is still pending.

The complete Linux GNATprove audit passed on the stable 5a Ada source: 2,797
checks (485 flow, 2,312 proof), 17 units, 257 entities, 63 classified limitation
notes and 14 imports. It used the existing warm sessions/cache with forced full
analysis and four workers; it is not a cold timing. Native evidence is canonical
and the transcript is `native-full-5a.log`. Complete Lean source correspondence
and the stable-input full suite remain pending. The added later-nested boundary
regression passed independently.

Isolated 5b drafts now include predicate semantics, interval/path facts and a
sound predicate refinement/bounds checker. Fresh axiom audits retain only the
standard foundations. The native integer-literal draft separately passes 49 SPARK
checks; it includes both `#` and paired-colon based delimiters (Ada 2022 J.2(3)),
as confirmed by the native frontend. Source integration and literal semantic
correspondence are still pending. Drafts live below the task evidence directory
and do not expand the supported language.

The 5a source-certificate target completed successfully at 00:40 UTC on
2026-10-14, with a fresh standard-axiom audit. The following source-body/contract
checks and full stable-input native test suite are still running. Isolated
5b/c edits have not changed those inputs.

The 5b/c native prototype now accepts/rejects all 166 selected draft admission
cases as expected, including Boolean grouping, literal spellings, short-circuit
bounds, affine length equalities, joins and invalid-input effects. Four native
integration compiles/proofs/run cases passed. A fifth program, using positive
input length without a validity query, discharged all 44 checks but failed the
old exact Main entity policy because `Input_Is_Valid` was absent. This is an
integration defect to repair using precise additional entity shapes; the proof
requirements are unchanged. The logs and source snapshots are retained in
`native-predicates/`. The separate path-fact package passed 32 SPARK checks.
These are draft experiments, not the final capability checkpoint.


At the 2026-10-14 checkpoint, the complete native suite ran 275 methods in
1,238.984 seconds. Two subtests in certificate-regeneration equality failed
because the root's OutputSpec/OutputBody candidates had not been synchronized
with the generated, kernel-checked lane copies. After copying those exact
candidates, all nine source-policy methods passed. All other full-suite methods
passed. Ada and native-test inputs were stable; the source-check proof renderer
was repaired during the suite, so this is not a claim of a fully frozen proof
tree. The repair replaces a nonreducing imported String split with a structural
character fold and explicit renderer unfolding. The final source checks passed,
including a fresh audit; the outer source bridge and canonical complete check
remain to finish. Logs are `native-full-tests-5a.log`,
`certificate-sync-tests-5a.log` and the certificates-lane logs.

The isolated 5b/c output-profile proof now passes all 807 checks. Precise extra
Main entity alternatives handle programs that use input and returning Reject
without calling Input_Is_Valid; positive reports and targeted missing-coverage,
callee, duplicate, unproved and wrong-policy mutations pass their expected
verdicts. The native report-checker SPARK run also passes. These changes remain
isolated pending the 5a checkpoint.

A path-refined assignment on invalid input exposed a required runtime-contract
fact: First_Or_Default returns the empty String when Input_Is_Valid is false.
Adding that postcondition and a behavior-preserving early invalid-input return
proved all 46 library/program checks in isolation. The corresponding Lean
runtime model and unchanged initializer semantics passed a focused fresh audit.
Integration must refresh the runtime source binding and actual-source proof;
the isolated result alone does not establish the final compiler's assurance.

All exact-source-limit predicate probes were admitted with the documented 8 MiB
stack: 1,994 condition parentheses, 664 nested not/primary pairs, 307 and-then
comparisons, 333 or-else comparisons and 210 nested if statements. The first four
were also proved, compiled and executed successfully. Their 4,097-byte neighbours
were rejected. At 2 MiB the deepest parentheses case raises Storage_Error;
this does not expand the existing validated stack configuration. Recognition
measurements and compile logs are retained in `native-predicates/boundaries/`.


The first 5a outer-bridge build reached the shared Compose source-header checks
but hit the configured 8 GiB Lean memory threshold in three exact-header facts
(literal_at, expression_at and capacity_at). No source mismatch was reported.
The completed dependency objects and failed log are preserved. The retry uses
a 16 GiB per-process threshold, two workers and four threads, after confirming
30 GiB available/reclaimable host memory. This is a resource retry, not a cold
run or a weakened source check; the complete checkpoint remains pending.

Isolated 5b/c source proofs now cover integer-literal grammar/value and path-fact
operations with exact native bodies, inhabited equations and standard-axiom
audits. Independent input corpora passed 4,234 literal cases plus 87 boundaries
and 3,684 path-set comparisons. The recursive predicate/body models establish
source readings, unique program meaning, safe checked lowering and modeled
obligation discharge; final native bridge integration and current-language
facade remain in progress. Typed recursive body interpretation and its concrete
model equations pass focused checks while the remaining bridges are completed.

The isolated runtime source proof now checks the strengthened invalid-input
postcondition, the early empty return, exact spec/body bytes and the existing
initializer semantics. A fresh audit passed with only the standard foundations.
The recursive body uniqueness proof and outer scan equations also pass focused
checks, with explicit model witnesses. Their final source bridge still depends
on integrating the predicate helpers and matching final source certificates.


## Completed 5a checkpoint — 2026-10-14

The stable final 5a inputs passed the canonical complete Lean check: 155 modules,
39,977 declarations, and only `propext`, `Classical.choice` and `Quot.sound`.
It reused the completed source-certificate lane artifacts, including all private
and server sidecars and Lake metadata. Build time was 698.547 seconds, the fresh
audit 4.180 seconds, and total runner time 706.147 seconds. This is a warm complete
check, not a cold-build or independent-kernel-replay measurement. Inputs and
results are preserved in `complete-5a-lean-evidence.json`,
`complete-5a-lean-proof.log` and `lean-complete-5a.log` in the task directory.

The final scanner termination measure is a weighted natural number instead of
a lexicographic pair. Lean 4.34 wraps non-Nat well-founded definitions in an
opaque identity that prevented concrete kernel evaluation in the examples. The
new decreasing measure preserves the parser equations and accepted language;
universal correspondence and concrete examples both pass. The failed controls
and the successful measure experiment are retained. The earlier 8 GiB source
header failure was resolved by the recorded 16 GiB retry, without weakening a
check.

The complete native audit proved 2,797 checks across 17 units; build, catalogue
and sample checks passed. The full suite's 275 methods and two stale generated
certificate subtest failures, followed by all nine repaired source-policy
methods passing, are recorded above. Native inputs were stable; the initial
suite is not represented as a clean invocation over frozen proof inputs. The
final complete Lean run used stable source, proof and runner inputs. Independent
source/pin review is preserved in `reviewed-output-independent-review.json`.

This checkpoint completes nested equality conditionals, `elsif`, optional `else`
and nonempty written arms, with inhabited native interpretation and selectors.
The Oracle and existing expression/source limits are unchanged. It does **not**
close roadmap item 5: predicates, integer literals, path-sensitive checks,
generalized input-guard/Reject placement, their integrated source correspondence,
and their stable final Linux checkpoint remain required and authorized.
