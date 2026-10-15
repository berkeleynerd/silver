# Silver handoff

Updated on 2026-10-15 on Linux x86-64. Read [AGENTS.md](AGENTS.md),
[oracle.md](oracle.md), [language.md](language.md),
[development.md](development.md), [roadmap.md](roadmap.md), and the newest
[session memory](docs/session-memory.md) before substantial work. Inspect Git
status and the live harness goal; historical goal states are not current instructions.

## Production solver allowance complete

Application compilation now uses `--steps=100000`. The owner-authorized change
passed current-runtime probes, supported static/dynamic compilation and execution,
focused driver/report-integrity tests, the full native compiler audit and complete
cached Lean validation. The [adoption record](docs/expression-headroom.md#production-adoption)
gives exact results and scope. Language limits and compiler-development proof
settings remain unchanged; larger-expression admission remains proposed.

Recovery is `tmp/step-budget-adoption-active.json`. Preserve canonical/isolated
caches, prior experiments and successful program directories. Publication remains
authorized; no new harness goal was explicitly requested. CLI memory was not
updated; this handoff and checked-in session memory are current. Earlier
checkpoints below retain their historical scope.

## Expression Headroom experiment complete

The authorized step-budget comparison is complete. Both retained 64-leaf failures
reproduced at 10,000 steps and proved at 100,000 steps, using modest memory.
The [record](docs/expression-headroom.md) gives the measurements and the scope of
the retained runtime. At that checkpoint, production settings and admission were unchanged;
the larger-expression extension remains proposed. Recovery is
`tmp/expression-headroom-active.json`; preserve its fresh isolated results/caches
and the original cases. That experiment changed no compiler or Lean inputs, so the
Admission Repairs checkpoint below supplied its then-current implementation evidence.
Publication remains authorized; no new harness goal was explicitly requested.

## Admission Repairs complete

The owner-authorized response to review `e2c4fc2` is complete as one milestone.
See the [roadmap](roadmap.md#admission-repairs--complete) and
[delivery record](docs/admission-repairs.md). Both admission repairs, matching
native/Lean source and semantic proofs, bounded documentation/tests and the
Names lexical identity guard passed the complete Linux checkpoint. The full
suite ran on frozen inputs. Every admitted source in the available corpus passed
full GNAT object code generation; the latest reviewer's private corpus was not
available and is not claimed as locally rerun.

Recovery: `tmp/admission-repairs-active.json`; evidence is under
`.silver/linux-x86_64/admission-repairs-20261014T234242Z/`. Preserve the original
review, canonical and isolated caches, sidecars/traces and unrelated scratch.
The larger Names adapter remains deferred under the documented interpretation
premise. No next capability or new harness goal was requested; the historical
goal remains complete. Publication remains authorized. CLI memory tools are
unavailable and were not updated. macOS, hosted CI and independent replay remain
outside scope. Earlier handoffs below are historical.

## Focused Source Checks complete

The owner-authorized single [roadmap milestone](roadmap.md#focused-source-checks--complete)
after Names and Calls is complete. Six import-only Lean edits narrow composed-source checks
to their relevant source certificates; statements, definitions and proof bodies
are unchanged. The whole-project module set is retained. See the
[delivery record](docs/focused-source-checks.md).

The complete Linux Lean check and fresh axiom/module audit passed, as did all
62 focused tests and isolated cache controls. The composed proof objects stay
cached after unrelated path edits; relevant source edits still invalidate the
appropriate checks. The existing native proof manifest matches its inputs,
reports and tools. The delivery record distinguishes reused evidence and the
metadata-comparison correction from fresh proof work and measured timings.

Recovery: `tmp/focused-source-checks-active.json`; it locates evidence and the
isolated baseline/control scripts. Preserve the canonical cache, sidecars and
all scratch. Publication remains authorized. No next language capability or
harness goal was requested. CLI memory is unavailable and was not updated.
The following sections retain earlier delivery handoffs as history.

## Completed Names and Calls

The owner-authorized Names and Calls delivery is complete, closing roadmap items
2, 6 and 7 within their stated fragment. Context clauses may be reordered,
grouped and repeated; `use` makes existing calls visible subject to local-name
hiding. `Put_Line (Item => ...)` and `First_Or_Default (Default => ...)` are
supported alongside positional actuals. Exact package sets, existing operation
semantics and the first/unique immutable argument initializer are retained.
See the [sample](samples/names_calls.adb), [language specification](language.md)
and [completed checkpoint](docs/names-and-calls.md).

The full native proof audit, build and catalogue checks passed. All test methods
have passing results for their relevant final inputs: the record distinguishes
the full run's certificate-copy parity failures from their repairs and focused
rechecks. Complete cached Lean/source validation and the fresh whole-project
axiom audit passed against the final content digest. The declaration count is
an axiom inventory, not independent kernel replay. Final proof repairs included
kernel-computable call rendering, direct flag simplification and shell uniqueness
from exact package sets; the semantic conclusions remain intact.

Recovery: `tmp/names-calls-active.json`; evidence:
`.silver/linux-x86_64/names-calls-20261014T153711Z/`. Preserve the canonical cache,
its prior-build backup, all isolated lanes, sidecars, traces, reports and scratch.
The tracked generated candidates now match regeneration exactly. The checkpoint
records the development proof timings separately from the short final cached run.

The bounded existing-feature consolidation is complete. Resource/capacity and
source-import performance follow-ups remain proposed in the roadmap; no new API
or next capability is automatically authorized. Publication remains authorized;
macOS proofs, hosted CI and independent replay remain outside this delivery.
The live historical Compose String Results goal is complete; no new harness goal
was requested. CLI memory is unavailable and was not updated. The checked-in
session memory carries this handoff; Git identifies the implementation commit
separately from baseline `04171a604b` and the earlier review targets.
The sections below retain earlier handoffs as history.

## Completed branch review repair (before Names and Calls)

The owner-authorized bounded repair of [review `4503d17`](docs/reviews/review-4503d17.md)
is complete. Static/static assignment lengths must agree even on unreachable
paths, while dynamic path refinement remains. Native admission, Lean source and
semantic proofs, specification and catalogue are aligned. The
[checkpoint](docs/branches.md#completed-repair-checkpoint) records successful
full native proof, 294 tests over stable final inputs, complete Lean/source
correspondence and fresh axiom audit, and independent cross-review. No independent
kernel replay was run. The review remains unchanged at its original target;
Git identifies the repair commit containing this handoff.

The three regression cases reuse the existing harness and dynamic assignment
method; no broad compile matrix or new test framework was added. The bounded
source links and documentation corrections are complete. Remaining low findings
and an observed source-import rebuild cost are explicitly deferred in the
[roadmap](roadmap.md#branch-review-repair--complete).

Recovery: `tmp/branch-repair-active.json`; evidence:
`.silver/linux-x86_64/branch-repair-20261014T144008Z/`. Preserve all caches,
sidecars, previous-object backups, isolated lanes, scratch and program directories.
Normal Lake invalidation repeated the baseline-native guard lane's expensive
source checks during integration; the record keeps both scopes and timings.
The final native/Lean evidence matches current source inputs, and final test
input snapshots have no changes. Subsequent completion edits are documentation.

Next proposed functional work is context/name rules and existing-call associations;
this completion does not authorize it. Publication remains authorized. The
historical live goal is complete and no new harness goal was requested. CLI memory
is unavailable and was not updated; checked-in session memory is current. Earlier
sections below retain the preceding deliveries' historical evidence and scope.

## Completed branches milestone (before review)

All authorized roadmap **5a–5c** are complete. The [delivery record](docs/branches.md)
and [roadmap](roadmap.md#equality-guards-and-branches-increments) record nested
conditionals, predicates/integer literals and path-sensitive composition.
5a was published in `dc5295eabe`; Git identifies the following 5b/c integration
commit. The combined Linux checkpoint passed with complete native and Lean
source correspondence. The full-suite run had three stale assertions, since
repaired and covered by the passing affected suites; the delivery record keeps
that scope explicit. The Oracle is unchanged.

The canonical `.silver/linux-x86_64/proof/` is the completed warm cache.
`tmp/branches-active.json` identifies recovery and retained evidence under
`.silver/linux-x86_64/branches-20261013T234331Z/`. Preserve earlier caches,
private/server sidecars, Lake traces, isolated lanes, failed attempts and scratch.
No optional independent replay or macOS run was performed for this checkpoint.

Next proposed consolidation work is **context/name rules and positional/named
call associations** for the existing packages and APIs, in roadmap items 2, 6
and 7. Their predicate/path integration is complete; new argument APIs remain
separate. This handoff does not authorize that next work. The historical Compose
String Results harness goal remains complete, without a newly requested goal.
Publication remains authorized, Actions is disabled and CLI memory is unavailable
and was not updated. Checked-in session memory records this completion.

## Completed review follow-up

The owner authorized bounded cleanup of
[review `9b99d52`](docs/reviews/review-9b99d52.md), before further functional work.
Documentation corrections, focused regressions and both selected dense
measurements are complete. The
[capacity record](docs/statement-sequencing.md#external-review-and-capacity-follow-up)
discloses dense compilation cost, precise report-policy changes, stack assumptions
and the original checkpoint's test/cache scope. The static 800-assignment and
argument-input 769-assignment results have been corroborated. Both complete
reports fit the application buffer; the latter leaves 5.4% headroom. Earlier,
the 55 affected test methods passed without skips, and the sequencing sample
passed six execution cases after a real compile.

The review's M1 is downgraded to low and the remaining disclosure is addressed.
An admitted single-target 771-assignment variant remains uncompiled, so these
measurements are not universal worst-case bounds. It is recorded for future
capacity work, not an open run in this bounded follow-up. No compiler, library or
Lean source changed; retained proof inputs still match. Neither long proof was
repeated, and no blanket proof or suite rerun accompanied the documentation closure.

Recovery: `tmp/sequencing-review-active.json`; evidence is under
`.silver/linux-x86_64/sequencing-review-20261013T223033Z/`. Preserve both reviewer
and local program directories, caches, scratch and prior records. The supplied
reviewer update is retained verbatim. Its target remains `9b99d52`; it explicitly
does not review cleanup commit `138c751` or the later documentation closure.
Publication remains authorized. The live
historical Compose String Results goal is complete; no new goal or language
increment began. CLI memory tools remain unavailable; this handoff and checked-in
session memory are updated.

## Earlier completed sequencing work

**[Statement sequencing and assignment](docs/statement-sequencing.md) is complete**,
based on `3c1522f540`. The implementation/review target is `9b99d52b447a65`.
It admits finite sequences of null, compatible
fixed-bound assignments, output and one-level String-equality choices, including
multiple choices and returning output failures. Existing argument guards,
expression bounds and the source limit remain; no statement/output-count cap
was introduced. The Oracle is unchanged.

The complete Linux native audit, build/catalogue checks, full test suite,
actual-source correspondence and complete Lean build/fresh axiom audit passed.
The capability record distinguishes the successful final checkpoint, reused
artifacts, failed proof attempts, native capacity observations and remaining
external solver/producer premises. The two selected dense cases have since
completed; the follow-up above records their costs and remaining scope limits.

Recovery: `tmp/sequencing-active.json`. The canonical `.silver/linux-x86_64/proof/`
is the preferred completed warm cache. Preserve prior evidence, isolated lanes,
private/server sidecars, Lake metadata, failed logs and scratch. The task record
notes the replaced model-lane rolling focused JSON; its timestamped logs and
separate witness evidence remain. Do not run concurrent writers in one workspace.

The later 5a–5c checkpoint above supersedes this sequencing checkpoint as the
current-language validation. Its evidence and source/cache scope remain intact.

## Previous completed work

The authorized narrow [composed-witness repair](docs/common-expressions.md#external-review-of-9b72d36)
is complete, based on review target `9b72d36015`. The implementation commit is
the commit adding `proof/Silver/ComposeModel.lean`. Its concrete witness satisfies
the original combined equations, range contracts and legal-call domains without
premises. Assurance wording retains the actual Ada/frontend interpretation
boundary. The complete cached Linux Lean build and fresh audit passed; source
certificates/source checks were reused and retained native evidence still matches.

Recovery pointer: `tmp/compose-witness-active.json`. Preserve its prior evidence,
canonical cache snapshot, isolated proof lanes, failed logs and supplied review.
The canonical proof workspace is current and warm. Accepted/rejected controls
will accompany admission rules when touched; broader review cleanup remains
deferred in the roadmap. Native behavior and admission rules are unchanged.
Statement sequencing is next proposed; no further functional work or new harness
goal began. The historical Compose String Results goal remains complete.
Publication remains authorized, Actions is disabled and macOS proofs are out of
scope. CLI recall tools are unavailable; checked-in memory is updated.

## Previous completed checkpoint

**Common String expressions is complete**, authorized by the owner's “Proceed”
and based on `7547b3d07d`. The [capability record](docs/common-expressions.md)
describes the shared literals, names, concatenation and parentheses in
initialization, assignment, comparison and output; affine bounds cover every
intermediate value and assignments preserve object lengths. The implementation/
review target is the commit introducing `samples/common_expressions.adb`.

Complete Linux native compiler verification, build/catalogue checks, universal
Lean semantics/obligations, actual-source correspondence and fresh whole-project
axiom/coverage audit passed. All test methods are covered across the full run
and the focused certificate repair; the initial full invocation was not clean.
Independent reviews found no remaining material mismatch. Optional replay and
macOS proofs were not requested. External frontend/generation/solver-completion
and complete-report capacity premises remain explicit.

Next proposed work is **statement sequencing and assignment** in the
[consolidation sequence](roadmap.md#existing-feature-consolidation), with output
effect composition where needed. Context/name/API closure and larger resource
fragments remain tracked. No further increment or replacement harness goal has
begun; the live historical Compose String Results goal remains complete.

Recovery pointer: `tmp/common-expressions-active.json`. Preserve its prior-state
snapshots, isolated workspaces, failed logs, scratch and the archived unfinished
repeated-output draft. The completed canonical `.silver/linux-x86_64/proof/`
is the preferred warm cache; retain all sidecars and Lake metadata, as well as
older cache generations. Native evidence matches the completed implementation/
tool inputs. Correct the minor spec-comment wording about operator count with
the next required source edit, as recorded in the capability review.

Publication authorization persists; Linux is primary, Actions is disabled and
macOS proof work is out of scope. CLI recall tools were rechecked and remain
unavailable; no CLI recall entry was written. Checked-in session memory is current.

## Shared-binding checkpoint

**Declarations, names and copies is complete**, authorized by the owner's
“Let's proceed with the next unit of work.” The
[capability record](docs/shared-bindings.md) gives its scope, complete Linux
native/Lean checkpoint, independent reviews and exact evidence. It replaces
fixed declaration slots with initialized binding lists, snapshots, mutability
and fixed/symbolic assignment bounds within the existing body arrangements.
The implementation/review target is the commit introducing
`samples/shared_bindings.adb`, based on `640d5cce9d`.

Its then-proposed common-expression follow-up is now complete as recorded above.
Context/name visibility closure remains paired with existing argument operations.
No replacement harness goal was requested; the historical Compose String Results
goal remains complete.

Recovery pointer: `tmp/shared-bindings-active.json`. Its task evidence directory
preserves the exact unfinished repeated-output source and patch, previous native
state, the former canonical proof workspace, focused workspaces, failure logs
and final validation. The unfinished draft is archived, not live support; its
rejected four-call cap is not adopted. Its completed canonical workspace was
preserved before common-expression work. The newer preferred warm cache is
recorded above; preserve both generations with all sidecars and Lake metadata.

Its native compiler evidence records the then-current implementation/tool inputs. The
full test run plus focused repairs covered all test methods; the initial full
invocation was not clean. The complete Lean check passed with a fresh module
and axiom audit; optional replay was not requested. Linux remains primary,
macOS proof work is out of scope and hosted Actions remains disabled.
Publication remains authorized. CLI recall tools remain unavailable and were
not updated; checked-in session memory is current.

## Earlier checkpoints

The status paragraphs below are historical; the completed common-expression
capability and current warm cache above supersede their proposed-next-work and
latest-cache statements.

The useful findings from the remote `codex/oracle-roadmap-audit-plan` branch are
[integrated with owner approval](docs/remote-plan-review.md). The Oracle now
requires explicit purposes for restrictions/resource limits and automatic checks
during project validation. Its Lean and universal assurance requirements remain.
The existing roadmap rows now cover source-derived driver/report requirements,
context/name syntax, call parameter associations, numeral parsing/short-circuit
facts and migration of rejection tests. The branch's alternative assurance policy
and obsolete support status were not adopted. This documentation task is complete;
shared bindings/copies remain next proposed implementation work.

**The restrictions and capacity audit is complete.** The
[audit record](docs/restrictions-capacity.md) classifies every current construct,
records bounded native proof/translation/report experiments and specifies the
shared binding/expression foundation. The selected-result catalogue now includes
its already supported constant-reference initializer; the admitted language is
unchanged. Broader expressions can exhaust the configured solver effort, and
dense sequences exceed this audit's bounded proof time. Report size for those
interrupted cases remains unmeasured. Preserve the distinction between completed
probes, externally interrupted experiments and universal assurance.

Next proposed work is **Declarations, names and copies**, with a shared finite
binding environment, initialized values, mutability, snapshot copies and fixed
object bounds. The common expression judgment follows or accompanies the pieces
that need it. New obligation classes and harmless diagnostics need precise
policies, and broader expression/effect composition needs justified capacity.
The [consolidation sequence](roadmap.md#existing-feature-consolidation) and audit
record define the scope; this audit does not authorize another implementation.
Its four open [audit follow-ups](roadmap.md#audit-follow-ups) are now explicit
within those items: length checks, ghost-output advisories, dynamic-expression
solver limits, and dense proof/report capacity.

Native build, focused tests, incremental GNATprove and the complete cached Lean
check with a fresh whole-project audit passed for the catalogue repair. This is
not a new full native audit or an independent kernel replay. Evidence is under
`.silver/linux-x86_64/restrictions-capacity-20261012T170230Z/`, with recovery pointer
`tmp/restrictions-capacity-active.json`. Its
`snapshot/.silver/linux-x86_64/proof/` is the latest checked warm seed; preserve
all object sidecars and Lake metadata. Native prior state is in
`preserved-before/`; the canonical Lean workspace and unfinished edit below
remain unchanged. The implementation/review target is the commit introducing
`docs/restrictions-capacity.md`, based on `a68d0b7f84`. No new harness goal was
requested; the live Compose String Results goal remains complete. CLI recall
is unavailable and was not updated; checked-in session memory is current.

The bounded **Lean Critical Path** work remains complete. Its final
[proof-authoring pass](docs/lean-proof-authoring.md), commit `a68d0b7f84`, adopts
one small declaration proof split: the matched two-file rebuild is 7.58% faster
and peak child RSS is 62.30% lower. Its evidence and previous warm seed remain
under `.silver/linux-x86_64/proof-authoring-20261012T163327Z/`. Source
correspondence, definitions, theorem statements and accepted axioms are unchanged.

Earlier evidence remains in the [baseline record](docs/lean-baseline.md),
[checked-witness optimization](docs/lean-join-optimization.md) (`5267935367`),
[module pilot](docs/lean-module-pilot.md) (`140de9abd6`) and
[adopted module migration](docs/lean-modules.md) (`15ca622139`). They separately
measure source-reconstruction work and proof-edit invalidation; their speedups
are not multiplicative. Their original input, platform and timing limits remain.
The canonical workspace retains the older certificate representation as preserved
evidence; use the latest warm seed above to avoid repeating completed work.

All 107 ordinary proof files now use module boundaries with their computational
interfaces exposed. Keep the complete and focused audit roots legacy so fresh
audits retain transitive private-declaration coverage. Source/public changes still
invalidate affected proofs; private proof edits can preserve consumer artifacts.
The current comparisons use 16,384 MiB per process on the 31 GiB sandbox. No host
allocation or Lean default changed. The owner's available 96 GB physical RAM
remains distinct from memory currently visible here.

**Close the existing features under composition** follows that bounded work.
The owner requested revisiting the narrow completed increments before accumulating
more isolated capabilities. The
[consolidation sequence](roadmap.md#existing-feature-consolidation)
defines the ordered work and closure criteria; the
[historical assessment](docs/language-generalization.md) records restrictions and
their reasons. The explicit fragment and restriction/capacity inventory are now
recorded. Implement the shared binding/expression foundations next, then compose
statements, branches and existing library effects. No new syntax is supported by
this planning update.

Repeated output was authorized on 2026-10-11, but its proposed four-call cap was
rejected as unjustified. Its scope is now part of sequencing and effect
composition. The sole preliminary code edit in
`proof/Silver/ComposeAdmission.lean` was uncommitted, incomplete and unvalidated;
it contained the rejected constant and is now archived in the active task
evidence directory, as described above. Preserve it and unrelated scratch; do
not attribute the previous checkpoint to this intermediate working tree.

The latest supported implementation is **Copy String Values**, commit
`e9d18f1996`, based on `96b98e1`. It adds up to two literal-backed constants before
the mutable result,
result initialization and equal-length assignments from either constant, and
constant references in bounded output expressions. The existing six output
shells and one terminal output per successful path remain. See the
[capability record](docs/copy-values.md) for scope, review and exact validation
inputs. The complete physical Linux checkpoint passed: native compiler audit,
build and full tests, complete Lean source correspondence and fresh axiom/coverage
audit. Optional independent replay was not requested. The implementation/review
target is the commit introducing `samples/copied_result.adb`, based on `96b98e1`.

This desktop chat recovered the completed CLI **Compose String Results**
context; it did not import that chat or reopen its goal. No active harness goal
was created for this increment. The previous capability is complete in
`96b98e1`, with [its original evidence](docs/string-results.md). The live harness
was rechecked on 2026-10-12 and has no active goal. Commit and publication
authorization persists; hosted Actions remains disabled. This documentation
update does not create a harness goal or change the Oracle.

The supplied [review of `d375aec`](docs/lean-iteration.md#external-review-of-d375aec)
has been assessed and its confirmed small repairs completed: reject direct
kernel-check bypasses in Lean inputs and retained build traces, test default-mode
failure paths and the real axiom audit, and strengthen assignment-membership
header correspondence. Complete cached Linux Lean validation and the affected
test suites passed without rebuilding source certificates. Replay remains optional.
The [three full final reviews](docs/lean-iteration.md#external-review-of-d375aec)
arrived in `26737d9`; their findings have been assessed and dispositioned.
Broader test promotion and comment-only proof-input edits remain deferred.
The retained native proof's
full manifest belongs to its original snapshot because the Lean runner changed;
its Ada and native configuration inputs remain unchanged. The repair/review target
is `767a33c`, based on `26737d9` and reviewing `d375aec`. That repair and the
earlier optimization goal are complete, as is the Copy String Values task above.

The [focused Lean runner](docs/lean-iteration.md) and selected workflow
simplification are complete. `check_lean.py --target MODULE` synchronizes current
inputs, builds the selected modules/imports and performs a fresh scoped axiom
audit. Default invocation remains a complete cached source-correspondence build
and coverage/axiom audit. Separate replay (`--replay`, alias `--full`) and detailed
provenance (`--provenance`) are explicit optional investigations. `--clean` no
longer implies replay. Focused evidence is separate and cannot establish complete
assurance. Native runner regressions, scratch replay/axiom probes and the complete
cached Linux check passed, preserving all twelve certificate objects. The completed optimization goal covered these changes; its implementation/review target is the
commit introducing `proof/Silver/AxiomAudit.lean`, based on `fe539a5`.

The bounded [Lean compartmentalization](docs/lean-compartmentalization.md) is
complete and adopted. Each embedded Ada file has its own Lean dependency, and
stable lexical/name helpers occupy a separate SPARK package. Complete Linux
native proof/tests, Lean build/axiom audit, fresh kernel replay and independent
evidence review passed. Existing evidence and caches are preserved. The
implementation/review target is the commit introducing
`src/silver_output_lexical.ads`, based on `1ed039e`. No language expansion occurred.

The owner authorized the runner follow-up after questioning routine replay and
bookkeeping. The workflow change retains actual-source proofs, correct
dependencies, fresh axiom/coverage auditing and input stability. No language
capability or further certificate framework was begun.

[Input-dependent branching](docs/input-branching.md) is complete: one String
equality on validated argv input selects two terminal literal-output branches;
invalid input reaches the existing rejection branch. All eight productions
passed the stable-input Linux checkpoint: native compiler audit, full test
suite, full Lean build, fresh axiom audit and independent fresh kernel replay.
Independent source review and final evidence corroboration found no material
findings. The Oracle, runtime operations and driver/report policies are unchanged.

The preceding branching implementation/review target is the commit introducing
[samples/input_branching.adb](samples/input_branching.adb), identifiable with:

```sh
git log --diff-filter=A -1 --format='%H %s' -- samples/input_branching.adb
```

It is based on `4422316`. The preceding assignment implementation and review
target `44fd8ea` retain their [completed evidence](docs/string-assignment.md).
The earlier branching and compartmentalization tasks did not request a replacement
harness goal. The runner follow-up later did, and that goal is complete. Recheck
the live state at resumption rather than treating historical goals as new instructions.
The [runner follow-up](docs/lean-concurrency.md#runner-follow-up) and
[native I/O optimization](docs/native-io-performance.md) also remain complete.

After observing the serial certificate cost, the owner requested end-of-day
checking or serious compartmentalization. The [workflow](development.md#proof-loop-and-validation)
now batches expensive source-correspondence checks at a stable end-of-session/day
checkpoint, with focused native/model checks during iteration. Preserve the
completed objects and caches. The bounded source/dependency assessment requested
before the next language increment is now complete, as recorded in the
[architecture follow-up](docs/architecture-review.md#proof-structure-and-the-expensive-rebuild)
and compartmentalization record. Changed-body checking and whole-project replay
remain expensive. The certificate representation is unchanged.

The former ordered increments are complete through Copy String Values. Their
narrow scopes retain their assurance. The
[current consolidation sequence](roadmap.md#existing-feature-consolidation) now
takes priority; do not equate those completed milestones with full compositional
closure or resume adding isolated whole-program templates by default.

## Local tools and evidence

The completed baseline ran on a Linux x86-64 sandbox with 12 available CPUs and
approximately 31 GiB RAM, without swap. The retained Copy String Values checkpoint
ran on the physical desktop with 22 CPUs and approximately 91 GiB RAM. Earlier
microVM evidence keeps its original attribution. These environments use the same
host-keyed artifact namespace, so determine the actual host and keep one writer
per cache. Native pinned tools and runtime readiness passed the read-only
handover check. The completed common-expression Lean checkpoint used 12 Lake
workers, 12 threads per process and the explicit `--memory-mb 16384` per-process
threshold on this 31 GiB sandbox. Earlier 12,288 MiB measurements retain their
original scope. The owner reports 96 GB physical RAM and can increase the
sandbox allocation; physical capacity is distinct from RAM exposed here.
Neither the host allocation nor the runner's default was changed by this task.
Use `python3 scripts/dev.py paths` for the actual
installation and artifact paths. GNATprove uses all cores by default; Lean uses
all available Lake workers and per-process threads, with independent overrides.
The [concurrency record](docs/lean-concurrency.md) distinguishes measured speedups
from remaining serial work and explains the per-process memory threshold.

During iteration, choose the smallest relevant check and use existing caches;
these commands are alternatives, not a sequence after every edit:

```sh
python3 scripts/dev.py build
python3 scripts/dev.py prove
python3 scripts/dev.py test -- -p test_branching.py
```

Choose tests for the affected behavior and batch edits before expensive
source-certificate rebuilds. Use `python3 scripts/check_lean.py --target
Silver.PredicateChecks --memory-mb 16384` for focused model feedback. Without a
target, a changed embedded Ada source still triggers its certificate rebuild.
Once a capability's inputs are stable, normally at the end of the session or
day, run the full test suite, `dev.py prove --full`, and `check_lean.py` without
a target. This retains complete compiler and source-correspondence validation
with cache reuse. Add `--replay` only for an explicit independent kernel audit;
it is no longer part of every checkpoint. Repeat only validation affected by subsequent
changes, failures or unresolved concerns. Documentation-only follow-ups need
lightweight checks. See the [validation cadence](development.md#proof-loop-and-validation).
Monitor aggregate host memory when running heavy
commands together. Preserve `.tools/<host>/`, `.silver/<host>/`, scratch files
and all foreign-host evidence. Source/runtime installation moves require
bootstrap and rebuild under the [platform coexistence rules](docs/platform-coexistence.md).

The review repairs' evidence is under
`.silver/linux-x86_64/review-d375aec-2026-10-11/`. The runner follow-up's evidence is under
`.silver/linux-x86_64/lean-iteration-2026-10-11/`. The completed partition's evidence is under
`.silver/linux-x86_64/compartmentalization-2026-10-11/`. The latest completed
capability's evidence is under
`.silver/linux-x86_64/names-calls-20261014T153711Z/`. The preceding branch evidence
remains under `.silver/linux-x86_64/branches-20261013T234331Z/`. Earlier common-expression
evidence remains under `.silver/linux-x86_64/common-expressions-20261013T152350Z/` and
`.silver/linux-x86_64/common-expressions-probes/20261013T152332Z/`.
Earlier Copy String Values evidence is under `.silver/linux-x86_64/copy-values/`; the preceding
composed-result evidence is under `.silver/linux-x86_64/compose-results/`.
The earlier branching evidence is under
`.silver/linux-x86_64/branching-validation/`, and the preceding assignment evidence
is under `.silver/linux-x86_64/assignment-validation/`. Earlier review follow-up records
are under `.silver/linux-x86_64/review-44fd8ea/follow-up/`. Native I/O measurements,
validation and preserved before/after reports are under
`.silver/linux-x86_64/native-io-static-2026-10-10/`. Prior canonical
reports/manifests are preserved separately from new runner checks. Earlier
host recovery and Linux ARM64 records retain their original input and platform
scope in the [host-readiness record](docs/host-readiness.md) and linked artifacts.
Linux is primary. macOS proof work is a non-goal for the current follow-up; retain
existing artifacts without seeking or rerunning macOS validation. GNAT Pro is untested.

<a id="recover-and-preserve-the-old-vm-evidence"></a>

## Git, recovery and session state

The owner authorized committing and publishing completed work to
[the repository](https://github.com/berkeleynerd/silver). GitHub Actions remains
**disabled repository-wide** by explicit instruction; validation runs locally.
Do not enable hosted CI as a follow-up. Verify remote `main` at handoff and record
the closing commit in the final response and local evidence.

The non-dot `silver/` and `tools/` transfer directories were removed from both
the tree and reachable Git history at the owner's request. Live `.silver/` and
`.tools/` were preserved. See the
[history rewrite record](docs/host-readiness.md#transfer-history-removal) for
commit mappings and recovery limits. Back up the ignored live directories
separately; a clone cannot recover them. Do not merge the old archive-bearing
history into the rewritten branch. Existing scratch, foreign-host artifacts and
safety stash `a48321d` remain preserved. Historical references are not instructions
to recover the removed archives.

For a clone that still has the old history, preserve the entire old checkout,
including `.git`, unpublished work, ignored `.silver/` and `.tools/`, and scratch
files. Use a fresh clone of the rewritten remote in a separate directory, then
port unpublished source changes separately. Do not merge or push the old branch
history into it. Restore live tools and evidence through staging, preserving
newer state, and follow the installation-move rules above before using them.

CLI memory is unavailable: no memory tool is exposed and the conventional recall
directories are absent. No CLI recall entry was updated. Checked-in
[session memory](docs/session-memory.md) is the durable handoff. The separate
Codex remote-control request remains unresolved because of API authentication;
this language task does not change authentication or restart its daemon.

## Remaining limits

The intermittent warm-state GNATprove `DOC_END` JSON-reader failure remains
unresolved. Retain a recurrence's logs and inputs; successful validation does not
establish repair, and no automatic retry is configured. Faithful complete GNAT
range/length obligation generation, pinned solver completion for the admitted
expression and fixed-length assignment fragment, complete report capacity, and the
frontend/runtime/environment assumptions remain explicit in
[assurance](docs/assurance.md) and the [trusted boundary](docs/trusted-boundary.md).
No new external operation or trusted shortcut is introduced by this increment.
