# Equality, guards and branches

The owner authorized delivery of roadmap **5a–5c** on 2026-10-13, based on
`7fb1514199`, continuing autonomously through implementation, validation and
publication. All three milestones are complete. Milestone 5a was published in `dc5295eabe`;
the coupled 5b/c extension passed its [combined Linux checkpoint](#completed-5bc-checkpoint--2026-10-14).
The original Oracle and external-tool assumptions remain in force. These
checkpoints describe the original delivery. The subsequent review and authorized
repair below address a build-completeness defect in that delivered admission rule.

The later review of `e2c4fc2` demonstrated that the static/static repair below
was incomplete: a static prefix plus dynamic input can also cause GNAT to reject
a dead assignment. [Admission Repairs](admission-repairs.md) strengthens the rule
to bound the static RHS contribution for every static target and adds a shared
literal-boundary repair. The earlier checkpoint and its test scope remain history;
they do not establish that all dynamic RHS spellings compile.

## Review of 4503d17 and bounded repair — 2026-10-14

The second-party review found one blocker: an unreachable assignment between
unequal statically known lengths could pass admission and GNATprove, then fail
GNAT code generation under the required `SPARK_Mode (On)`. Independent local
reproduction proved all 45 checks before the build failed; replacing the RHS
with an equal-length literal proved 44 checks and built successfully. The
retained reproduction is local-only at
`tmp/review-4503d17-assessment-3gawq7tr/`. This is a build-completeness defect,
not evidence of unsafe execution or a false Lean safety theorem.

The owner authorized this bounded repair before further language features:

- Require equality whenever both assignment lengths are statically known,
  even on unreachable paths. Preserve dynamic path-refined assignments. This
  explicit pre-1.0 rule avoids depending on which dead arms GNAT folds away;
  it does not amend the Oracle, rewrite source or weaken SPARK mode.
- Exercise three cases in the existing test harness: the rejected mismatch,
  an admitted equal-length sibling that compiles/runs, and the existing dynamic
  assignment test justified by path facts that compiles/runs. The latter two need
  actual code generation because `-gnatc` missed the defect. Existing sample
  tests already compile/run their programs; no duplicate stage or blanket
  differential-corpus compilation is added.
- Strengthen the existing source claims with token-list agreement, integer
  literal byte bindings, and local precedence/scope checks (review L10).
  These are source-correspondence repairs, not a new parser framework.
- Correct static-bound wording, restriction purposes, stack premises, source
  binding counts, local evidence paths and historical validation scope
  (L2–L8), and record the completed dense specimen below.

Broader negative-test cross-products (L1), historical-language retention
theorems and expensive concrete sample witnesses (L11), informative catalogue-template declarations and
manifest-tag cleanup (L12–L13), stack redesign, legacy-module cleanup and
the `silver run` failure-message improvement (L9) remain deferred. These low
items can be revisited when their grammar, samples or driver behavior are next
touched; they are not required to repair static assignment compatibility. The latter
can report a specified Reject as an external failure; it does not alter the
program's defined rejection behavior. Source comments that predate the generalized
guard/report policy are retained for now to avoid unrelated certificate rebuilds;
current rules are in the specification and assurance documents.

Two review qualifications matter. Its “warm replay” was an incremental build
and fresh axiom/module audit; no independent kernel replay ran. The 53,422
declarations are the axiom-audit population. Its I10 missing-anchor claim does
not hold: `RESUME.md` has an explicit `recover-and-preserve-the-old-vm-evidence`
anchor. The reported foreign `tmp/greeting-example-9rp5sciv/` directory is our
preserved scratch from the owner's example request, not unexplained review work.

The repair uses focused checks while inputs change and one stable final Linux
checkpoint. Earlier caches, failed evidence and the original review are preserved.
The [roadmap](../roadmap.md) records the completed repair and deferred work;
the original delivery checkpoints below do not validate this repair.


### Completed repair checkpoint

Review target: `4503d17a93d97af62d0fea9f61990ed1df23a882`. The repair is a
subsequent explicit pre-1.0 admission change; the original review is preserved
unchanged. Local-only evidence is under
`.silver/linux-x86_64/branch-repair-20261014T144008Z/`, with recovery pointer
`tmp/branch-repair-active.json`.

- The new mismatch regression failed against the old binary, then passed after
  the repair. Its equal-length sibling proved, compiled and ran; the existing
  dynamic path-refined assignment test also passed. One new test method supplies
  the first two cases; the third reuses an existing method. An initial focused
  command named the catalogue test class incorrectly; both behavior methods
  passed, and the corrected catalogue invocation passed separately. All logs
  remain retained.
- The full native audit passed **3,049 checks** across 19 units and 301 entities:
  549 flow and 2,500 proof checks, with 74 classified limitation notes and 14
  imported entities. The normal solver cache was reused; this is full validation,
  not a cold timing measurement. `native-proof-evidence.json` and `gnatprove.out`
  retain the provenance and totals.
- The complete suite passed **294/294 methods**, without failures or skips, in
  **1,011.244 seconds** (the wrapper recorded 1,011.532 seconds). Its preceding
  build and catalogue equality check passed. `final-tests/results.json` records
  native/script/test/sample/catalogue/project and proof source hashes before and
  after; both changed-input lists are empty. No later code or proof edit is
  included under this result.
- Focused Lean validation checked the repaired source shape, semantic safety,
  native/model equality and all 22 path precedence guards. Only the path source
  certificate changed; its isolated rebuild took 165 seconds. The separate guard
  lane checked the aggregate token, literal-byte and predicate precedence/scope
  claims; its composed source-check module took 1,159 seconds. One earlier path
  equation attempt failed on Boolean grouping; the corrected left-associated
  interpretation passed, without changing the native condition. The frozen final
  tree includes that correction.

The integrated complete Lean/source-correspondence checkpoint **passed** with
**242 modules and 53,490 declarations axiom-audited**, using only `propext`,
`Classical.choice` and `Quot.sound`. It took **1,127.623 seconds**: 1,121.572
seconds for the incremental build and 3.355 seconds for the fresh axiom/module
audit. The run used two Lake workers, four threads per Lean process and a
24,576 MiB per-process threshold on the twelve-CPU, 31 GiB Linux sandbox.
`lean-evidence.json`, `lean-proof.log` and `lean-complete.log` retain exact scope.
This is neither a cold build nor an independent kernel replay.

Matched-source objects were copied with private/server sidecars and Lake traces,
preserving previous canonical objects under `cache-before-promotion/`. The guard
lane used reviewed-baseline native bytes. Normal Lake dependency invalidation
therefore rebuilt its transitive importers against the repaired path source,
including `ComposeSourceChecks` in 920 seconds; no traces were rewritten to claim
a cache hit. Both isolated and integrated results are preserved, and their times
must not be represented as one cached invocation. The public source-certificate
import chain caused that extra work; narrower imports are a proposed roadmap
follow-up, not part of this repair.

The final native and Lean evidence input identities match the repaired tree;
recorded native reports are unchanged. The full suite's frozen code/proof inputs
remain the final inputs. Completion edits are documentation only. B1 and the
selected bounded follow-up are complete; the low items explicitly deferred above
remain deferred. No dense application proof, independent replay, macOS proof or
hosted CI run was added.

Independent read-only cross-review found no issue in the static compatibility
rule, retained dynamic behavior, source links or regression/catalogue changes.
The complete original review is retained separately from these repair results.

## Delivery sequence

1. **5a — complete:** nested String-equality conditionals, `elsif` and optional
   `else`, retaining the existing outer input guard and expression/source limits.
   Branches contain existing statement sequences. Retain exact source syntax in
   the model, including the distinction between `elsif` and a nested `if`.
2. **5b — complete:** explicit predicate/Boolean grammar and integer-literal
   spellings, preserving Ada evaluation and lexical rules. Establish safe
   short-circuit evaluation, overflow-safe parsing and justified exclusions.
3. **5c — complete with 5b:** path-sensitive expression/assignment checking,
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
workaround. Do not suppress obligations, silently narrow admitted inputs or
declare partial work complete to avoid a failure.

`tmp/branches-active.json` records the baseline, evidence directory and isolated
proof lanes. The initial Linux sandbox has twelve CPUs and 31 GiB RAM, no swap;
the owner's larger physical-host memory is distinct. Preserve the warm canonical
proof cache, private/server sidecars, Lake metadata and the saved pre-task native
reports/compiler/Lean evidence. Input/model/source changes must be reviewed
together; source-pin regeneration alone is not correspondence.

The checkpoints below complete all three increments. This record and the
[roadmap](../roadmap.md#equality-guards-and-branches-increments) preserve the
development chronology, failed attempts, actual input scope and remaining
consolidation work outside item 5.

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


## Coupled 5b/c integration — 2026-10-14

The isolated predicate/literal grammar, path-sensitive semantics, source reading,
unique meaning, report selectors and all seven Current example modules pass
focused kernel checks. The final executable predicate-tail implementation
proves all 766 output-profile checks in its isolated native unit run. It preserves
the typed recursive equations while avoiding duplicated loop/refinement work.
The integrated runtime normalizes invalid input to empty bytes under its verified
contract; its source binding and exact runtime proof are refreshed together.

The final recursive parser passed ten exact-4096-byte recognition shapes at the
documented 8 MiB stack, including mixed condition grouping, Boolean chains,
nested statement bodies, `elsif` arms and dense null sequences. Their 4097-byte
neighbours were rejected. The 1994-parenthesis 2 MiB negative stack control still
raises Storage_Error; 2 MiB is not the supported configuration for this extension.
`boundaries-executable-tail-20261014T0200/` under `native-predicates/` records exact
build inputs and measurements, preserving the earlier implementation's records.

An independent review exercised 76 mutations of genuine query-free Main reports
against the integrated native checker. Required callees, complete coverage,
approved dependencies, diagnostic classes and proved safety records remain
enforced. Positive program proof evidence is reused with its actual inputs;
these mutations are report handling tests, not new program proof runs.

The complete source interface explicitly composes inherited lexical/expression
helpers, literal equations and refinement, native path-body projections, predicate
meaning, basic statements, recursive bodies, adapters and outer scanning.
Formal totalizations choose model values only outside checked native call domains
and retain all in-domain values. They introduce no executable check, replacement
source or assumed scanner equality. Native contracts and GNATprove establish
executed-call legality. An explicit simultaneous model witness remains required
and is checked with the full interface.

At this stage of integration the final native audit and source-certificate run
were still in progress. Catalogue review identified stale guard metadata left
over from the former fixed shells; its correction and final test/Lean checkpoints
were completed below. Earlier 5a source-specific bridge modules were retired
from the current source assertion. Retained sequence mathematics remains audited;
some effect/store lemmas are reused, while other legacy modules currently have
no consumers.


## Bounded 5b/c capacity assessment — 2026-10-14

Removing the fixed guard permits **782 single-target dynamic assignments** in
4095 bytes, or **779 alternating-target assignments** in 4092 bytes, followed
by unconditional `Silver_Arguments.Reject`. The single-target shape uses 185
fixed bytes plus five per assignment. Both maximal specimens pass native
admission; one extra assignment exceeds the unchanged 4096-byte source limit.
The static alternating shape still fits 800 assignments; the 802 self-assignment
shape was already available. Evidence paths in this section are **local-only**,
under the ignored directory
`.silver/linux-x86_64/branches-20261013T234331Z/capacity-bounded-review/`.
`compact-counts.json` retains exact inputs, hashes and admission results;
`argument_single_reject.adb` is the 782-assignment specimen. It was uncompiled
at the delivery checkpoint and was subsequently proved and built during the
review of `4503d17`, as recorded below.

One isolated 16-assignment source, `dynamic16/main.adb`,
using the current runtime contract completed the normal application proof command
in 7.426 seconds: all 60 checks proved and the five-unit report audit passed.
Its 44,939-byte Main report contains 16 length checks and 17 classified advisories.
Each length check has three proof subgoals, matching the retained 769-assignment
report. Its command, inputs and result are in `dynamic16/result.json`, and its
report audit is in `audit.json`. At that checkpoint, scaling the retained
769-case record sizes to 782 estimated
**2,017,312 bytes (96.2% of 2 MiB), leaving 79,840 bytes**. This is an estimate,
superseded for this specimen by the review's measured report, not a universal
report bound. The historical
800/769 completion measurements remain distinct.

Seven additional exact-4096-byte admitted sources passed native admission and
GNAT syntax/type frontend checks, each in under a second. Their 3982-byte numerals
cover isolated separators in decimal, base, mantissa and exponent positions,
leading-zero based mantissas, and colon-delimited base/mantissa variants. The
commands, source hashes and results in `literal-frontends/results.json`
complement the retained plain leading-zero decimal/base/exponent and exponent-4096
frontend probes. These are frontend checks, not full application proof runs.

The original bounded assessment in `assessment.json` found no demonstrated report
overflow, new per-check splitting or frontend defect. The later review's normal
compile of the dense specimen proved **826 checks**, including 782 Main length
checks, and built its executable. Its **2,013,253-byte** Main report uses **96.0%**
of the 2 MiB buffer and leaves **83,899 bytes (4.0%)**. The source and proof
report were independently corroborated in the retained local program directory
`.silver/linux-x86_64/program-a90pEV/`: the source is byte-identical to the
4095-byte specimen and the report has 782 Main proof records and 783 advisories.

The reviewer reported **2,014.5 seconds (33.6 minutes), 6.1 GiB peak memory**,
and executable status 1 with no output for no argument, `hello`, an empty
argument and two arguments, as specified by its unconditional Reject. The run
overlapped review probes; timing and peak memory are reviewer-attributed
observations, not an independently rerun or clean performance benchmark.
This closes the selected specimen's completion/capacity caveat. No dense rerun
or new membership/resource cap was added. It is not a universal report bound. Every
admitted source must still fit the producer/report envelope and complete under
the documented external-tool assumptions; an actual overflow or proof failure
would be an implementation defect.


## Final checkpoint repairs — 2026-10-14

The first integrated native run proved all 3,049 SPARK checks, then the evidence
audit correctly rejected two `operator-reassociation` warnings in the new
integer-literal helper. Explicit parentheses around each character-position
subtraction preserve its computation. The corresponding typed source expressions,
complete body pin and generated certificate are updated together; the strict
warning policy is unchanged. The failed run, reports, sessions and original
sources are preserved under `native-catalogue-final/`. The refreshed native
audit also incorporates the final catalogue correction.

Independent final bridge review restricted the statement adapter's stop-token
premise to the native `else`/`end` contract. The scanner uses `end`; the model
witness and focused axiom audit still pass. No out-of-contract adapter equality
is needed. `documentation-proof/final-bridge-review.json` records this repair.

The refreshed run also proved all 3,049 checks, but its complete diagnostic scan
found seven more reassociation warnings: one literal-scanner termination measure,
one literal-scaling loop invariant, and five predicate-scanner termination
measures. These are grouped explicitly in one repair batch, including all exact
source-header and certificate checks. The second failed audit and its unchanged
input scope are preserved separately. Source changes are prepared in isolated
lanes while the full test suite retains its frozen inputs. No warning is newly
allowed or suppressed.

The integrated full suite completed 293 methods in 1,108.297 seconds and exited
1. Its source/script/test/proof inputs were stable during that run, but twelve
files changed before the published `4503d17` tree:

- Native: `src/silver_integer_literals.adb` and `src/silver_output_profile.adb`;
  later edits added parentheses in variant, invariant and termination expressions.
- Proof: `ComposeSourceChecks.lean`, `IntegerLiteralBodyCertificate.lean`,
  `IntegerLiteralSourceChecks.lean`, `IntegerLiteralSourceShape.lean`,
  `OutputBodyCertificate.lean`, `PredicateNativeSourceChecks.lean`,
  `PredicateSourceBridge.lean` and `ReviewedOutputShape.lean`, all under
  `proof/Silver/`.
- Tests: `tests/test_arguments.py` and `tests/test_evidence.py`.

Three subtest assertions were stale: one
rejected a safe trailing null after an argument conditional, and two required
Input_Is_Valid in otherwise complete query-free reports. Every other case,
including the new predicate/path runtime tests and all manifest samples, passed.
The prepared fixture repairs admit those newly supported cases while retaining
a malformed-statement neighbour and missing-required-callee controls. Final
focused reruns cover both repaired modules and the source-certificate policy;
the suite is not described as a clean, failure-free invocation.

The final grouped-source native build and catalogue equality check passed. Its
warm complete GNATprove audit passed in 59.894 seconds: 3,049 checks across
19 units and 301 entities, comprising 549 flow and 2,500 proof checks, with
74 classified limitation notes and 14 imported entities. The complete evidence
audit accepts these reports. This is cache-preserving full analysis, not a cold
proof measurement; captured inputs were stable. Exact provenance, reports and
phase input scopes are retained under `native-variant-final/`.


The final focused rerun passed **52/52 tests** in 98.413 seconds, with no errors
or skips, across `tests.test_arguments`, `tests.test_evidence` and
`tests.test_lean_source`. It covers the repaired admission/report fixtures and
source-certificate policy after the final grouping batch. Native, script, test,
proof, sample, generated and project input hashes remained unchanged throughout
both the successful full native audit and this focused rerun. The compiler
rebuilt in 1.479 seconds, and its catalogue still matched the tracked JSON.
The local-only `native-final-handoff.md` and `native-variant-final/results.json`
under `.silver/linux-x86_64/branches-20261013T234331Z/` record that exact scope;
preserved final reports and their hashes are in the same evidence directory.
The earlier full-suite invocation and failed audit attempts remain preserved as
separate records. This focused rerun preceded the two proof-only changes recorded
next; it was not a test run over the final published proof tree.


The first canonical complete Lean attempt exposed one stale inherited
`finite_mapping` assertion: its expected word-token list omitted `or` and `not`,
although both the native enumeration and model already included them. The build
reported that false proposition, retained the successful unrelated modules and
exited after 1,550.404 seconds. The exact failed input and logs are preserved in
`failed-final-token-mapping/`. The assertion now includes both words; independent
review confirmed there was no second omitted enumeration. This proof-only repair
followed the native and affected-test checkpoint; it changed no native source,
source pin, runner, sample or test. The complete Lean check resumed with the
same settings and caches. No assertion or source check was removed.


The next complete attempt passed `ComposeSourceChecks` in 853 seconds and its
source bridge, then found the final predicate bridge lacked an explicit import
of `IntegerLiteralSourceBridge`. The declaration already existed and had passed
its isolated source check; adding the import makes that dependency available to
the composed bridge. The failed attempt lasted 860.354 seconds and is retained
in `failed-final-bridge-import/`. This is the second proof-only integration
repair after the native checkpoint; native/script/test/sample inputs remain
unchanged. Successful source checks stayed cached for the resumed complete run.


## Completed 5b/c checkpoint — 2026-10-14

All authorized milestones **5a–5c are complete**. The final canonical Linux
check passed with **241 modules and 53,422 declarations axiom-audited**, using only
`propext`, `Classical.choice` and `Quot.sound`. The build took
8.508 seconds, the fresh axiom/module audit 3.337 seconds,
and the complete runner 14.214 seconds. These are warm timings
for the successful final attempt, excluding earlier isolated checks and the
preserved failed attempts; they are not cold-build or total-development timings.
Exact results and streamed logs are in `complete-5bc-lean-evidence.json`,
`complete-5bc-lean-proof.log` and `lean-complete-final.log` under
`.silver/linux-x86_64/branches-20261013T234331Z/`.

The run used one Lake worker, four threads per Lean process and the explicit
24,576 MiB per-process threshold on the twelve-CPU, 31 GiB Linux sandbox. It
reused checked isolated-lane objects and earlier successful canonical objects,
including private/server sidecars, IR and Lake traces. The previous canonical
cache and promotion inventory remain preserved in `final-cache-promotion.json`
and its linked backup. The complete source bindings/certificates and all current
bridges passed; the final fresh audit covered the complete imported module set.
Optional independent `leanchecker --fresh` replay was not requested or run.

The final native build and catalogue equality check passed. The complete warm
native audit proved **3,049 checks** across 19 units and 301 entities, with the
strict evidence audit accepting every required report. The initial complete
suite ran **293 methods**, exited 1 and had three stale subtest assertions; the
repaired
argument/report/source-policy suites then passed **52/52 methods**, without
skips. All other full-suite cases, including new predicate/path tests and all
fifteen manifest samples, passed. This is combined full-suite and focused-repair
evidence, not a failure-free full-suite run over the published tree. The twelve
files changed after the full suite are listed above. The final native inputs are
unchanged after the successful native checkpoint. The later Lean assertion and
bridge-import repairs
are recorded separately in `post-native-input-delta.json`; the successful final
Lean run checked its exact frozen proof inputs. No duplicate native audit was
needed for those proof-only repairs or these completion documentation edits.
The second-party review subsequently reran all 140 tests that read proof or
evidence files at `4503d17`; it reported 140/140 passing in 173 seconds across
`test_lean_source`, `test_lean_modules`, `test_lean_evidence`, `test_evidence`,
`test_proof_provenance`, `test_platforms` and `test_argument_bounds`.
This is attributed review evidence, distinct from the implementer's checkpoints.

Independent source/pin reviews and the final read-only bridge/policy review found
no material issue; `final-read-only-review.json` records their scope. The complete
simultaneous model witness inhabits the literal, path, predicate, statement and
outer scanner interpretation. Membership, selectors, unique source meaning,
checked execution, modeled discharge, invalid-input rejection and cumulative
effects compose with the existing explicit frontend/native/tool contracts.
No project-specific axiom, unchecked proof shortcut, weakened source check or
relaxed diagnostic policy was introduced. The Oracle is unchanged.

At this delivery checkpoint the bounded capacity assessment above was an estimate
for the uncompiled 782-assignment specimen; the later review completed that run
and its measured report fits, as recorded above. Context/name rules and
positional/named associations
for existing calls remain proposed consolidation work; new APIs remain separate.
The [roadmap](../roadmap.md#equality-guards-and-branches-increments) now closes
the parent item and all three increments without erasing those remaining areas.
5a was published as `dc5295eabe`; Git identifies the following integration commit
containing this final record. Earlier reviews retain their original targets.
All caches, scratch and failed evidence are preserved. Linux is primary;
macOS proofs and hosted Actions remain outside this delivery.
