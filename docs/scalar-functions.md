# Small nonrecursive scalar functions

**Owner-selected work, 2026-11-07; implementation in progress.** Existing
[#298](https://github.com/berkeleynerd/silver/issues/298), in
[milestone 20](https://github.com/berkeleynerd/silver/milestone/20), **Small
nonrecursive functions**, is one cohesive work package. The
[dated authorization](session-memory.md#2026-11-07--small-nonrecursive-functions-selected)
records the owner's **“Proceed”** after the recommendation to start with Integer
and Boolean scalar parameters/results, acyclic calls and no caller-visible
mutation. The working-branch [language](../language.md) and
[catalogue](../catalogue/silver.json) now specify the selected fragment below.
Function support remains pending complete implementation and assurance.

The integrated implementation checkpoint is published in draft
[PR #339](https://github.com/berkeleynerd/silver/pull/339). The PR remains in
progress; its publication does not complete validation or authorize merge.
The [Rosetta stage record #341](https://github.com/berkeleynerd/silver/issues/341)
tracks the precise `scalar-functions` mapping within #298. Its current Stage 8
field reflects the motivating task's existing broad-functions position; no
support promotion or rendered coverage gain has occurred.

Routine planning publication and merge, followed by implementation through
reviewable publication, are authorized. Implementation merge remains a later
owner decision. No next feature is selected. The completed sample expansion
[#300](https://github.com/berkeleynerd/silver/issues/300) merged through
[PR #337](https://github.com/berkeleynerd/silver/pull/337); it is not an outstanding
dependency of this work.

## Bounded capability and first driver

Admit small user-defined nonrecursive functions with Integer/Boolean scalar
parameters and results, an explicitly decidable acyclic call discipline, and
no caller-visible mutation. Reuse existing scalar bounds, Boolean expressions,
guards, declaration visibility and finite control flow wherever their current
rules suffice. Specify the exact admitted declaration, call and return forms
during the native/Lean design, before representing any form as supported.
The selected grammar and proof mechanism are recorded below.

The first driver is a Boolean `Is_Prime` function for
[Primality by trial division](../rosetta/p/primality-by-trial-division/task.wiki).
The task explicitly asks for a Boolean function; an inline calculation in Main
does not fulfill it. Use trial division and a bounded declared input domain
including negative values, zero, 1, primes and composites. Return nonprime for
1 and all non-positive inputs, and include independent expected results for
boundary, prime and composite cases. Bounded existing
Integer/loop/division machinery should suffice; the task permits loops other
than a square-root loop. Do not import the old assessment's anticipated while
loops, extra procedures or other unadmitted constructs merely to match its
sketch. A faithful bounded implementation and reviewed assessment determine
any coverage change. GCD and numeric search helpers remain candidate uses, not
additional promised sample deliveries.

Recursion, `out`/`in out` parameters, array or String signatures, general
procedure/package admission, generics and capacity rewrites are outside this
package. The Oracle and the existing trusted-tool boundary remain unchanged.
Local implementation state may be considered within the selected no-mutation
boundary; its exact permitted forms and observable effects must be explicit.

## Selected grammar and mechanism — 2026-11-07

The native/Lean design selected the following bounded fragment. Implementation
and validation are in progress; these decisions are not a support claim.

- Ordinary Main-local function bodies appear in the ordered declaration list.
  Each has a nonempty formal list, one name per formal and explicit `in`.
  Types are visible predefined Integer/Boolean or earlier named Integer
  subtypes. Actuals are positional. There are no defaults, overloads, forward
  declarations or nested function declarations.
- Calls are the whole RHS of assignments to existing mutable scalar Integer
  or Boolean objects. Calls are absent from initializers, arithmetic, guards,
  output/Image/indexing, returns, array-cell assignments and other actuals.
  This scope keeps evaluation and return composition separate from the existing
  expression grammar. Every actual uses the same incoming state: an earlier
  Boolean actual cannot refine a later actual, because Ada does not require
  left-to-right argument evaluation.
- Integer actuals have nonempty inferred intervals contained in formal ranges.
  Integer results contribute their declared result range, which must fit the
  destination; they do not inherit a particular call's values. Boolean results
  carry no argument, scalar, String-bound or input-validity facts.
- Bodies are checked once over the full product of formal ranges, including
  unused functions. They have initialized local Integer/Boolean scalar objects,
  then zero or more local assignments, earlier-function calls, null statements,
  conditions or counted loops, followed by one terminal typed return. Early
  return and function-specific contracts are excluded. There is no outer-value
  capture, caller mutation, I/O, input query, Reject, local String/Character/array
  state or local subtype declaration.
- Local initialization retains exact snapshots and staticness rules but cannot
  read formals, captured objects or calls. Body frames place initialized locals
  before immutable, nonstatic formals internally; the formal suffix permits
  existing scalar guard refinement without making formals mutable. Scope checks
  reject local/formal duplicates and collisions with earlier subtype names.
  Outer name hiding survives the closed value environment. Local names and loop
  binders can hide earlier functions.
- Only completely accepted functions become callable. Earlier-only calls and
  finite counted loops establish termination without recursion or assumed
  function contracts. A typed evaluator must be constructed from this prefix
  order; a separate model or assumed result oracle is not completion.

One-name explicit-in formals preserve existing source-derived binding capacities:
`X:in T;` (or the final `)`) costs at least seven bytes, and `X:in Boolean;`
costs thirteen. Locals, formals and loop binders require disjoint source charging.
Function metadata has a single source-wide pooled formal table outside recursive
body/flow frames; no per-function copy of the whole formal pool is needed.
The complete-source limit remains 4,096 bytes, each expression retains its
64-operand limit, and all function and Main operators share the same 63-operator
budget. The new signature capacity is source-derived: each accepted complete
function consumes more than 32 bytes, so `4096 / 32` slots suffice. The source
correspondence must establish this accounting before delivery.

Native probes use the unchanged application source and production switches,
adding `--no-inlining` for function-bearing programs only. This makes GNATprove
analyze each local function over its formal domain, including unused functions,
instead of repeated contextual inlining. Reports identify Main and individual
`Main.F` entities. The auditor must require their exact source-derived coverage,
classify successful `SUBPROGRAM_TERMINATION` flow records, retain every safety
obligation, and account for local `CLAIM_EFFECTS`/`CLAIM_AORTE` dependencies.
The native executable, bounded/unbounded models, projection and Lean source
bridges must agree; accepting a generic Main prefix is insufficient.

The exploratory run `20261107T172711-bb53bdee4857` had a successful GNATprove
process but a failed managed outcome because its input capture included changing
generated files. That failure is retained. Exact-file probe
`20261107T172925-d1dec7c49eb6` passed seven checks with `--no-inlining`.
The selected-grammar probe `20261107T173133-e00faebcc964` passed nine checks,
including an unused function's guarded division, termination and full coverage.
These are mechanism probes, not complete compiler or feature validation.
The exact sources, reports and managed records are retained in the
[mechanism-probe packet](evidence/scalar-functions-20261107/mechanism-probes/README.md),
including the failed input-capture outcome. These remain producer observations
from before compiler implementation. The integration installation
at `tmp/scalar-functions-298` copied the existing native tool release/cache from
`tmp/empty-loop-repair` and ran bootstrap to create its own Alire settings,
context, generated installation paths and Image overlay. No old native proof
result is attributed to this new installation.

## Work rounds

| Date (UTC) | Selected model/effort | Intended result | Result and remaining work |
| --- | --- | --- | --- |
| 2026-11-07 | Planning: GPT-6.1 Sol / High; native and Lean design: GPT-6 Astra / Extra High | Record authorization and settle a coherent first function fragment | PR #338 merged the plan; native probes selected full-domain `--no-inlining`; grammar and interfaces chosen above. Implementation, correspondence and complete validation pending. |
| 2026-11-07 | Native parser, Lean model and report integration: GPT-6 Astra / Extra High; lead runtime setting not independently exposed | Implement the selected rules, test boundaries and first driver | Three isolated implementation streams active; lead prepared typed call/domain/scope regressions and bounded `Is_Prime` driver. No completed feature assurance claimed. |
| 2026-11-07 18:54–19:14 | Continuing native/declaration, semantic and body/source streams: GPT-6 Astra / Extra High selected; resumed lead runtime setting not independently exposed | Connect function declarations and calls to the existing compiler source proofs | Function-declaration exported-state validity passed focused run `20261107T190725-f2c18256bc3f` (13,770 declarations); call-source reading/checkedness passed `20261107T190752-25ffaaf049d5` (98 modules, 10,953 declarations). Independent subtype/array source readings needed the new function/formal hiding guards; repairs are in progress. Typed native call/body integration, complete checkpoints and review remain pending. |
| 2026-11-07 19:19–19:41 | Same three selected GPT-6 Astra / Extra High streams; lead runtime setting not independently exposed | Repair inherited declaration guards and connect native function source domains | Array and String denotations now retain the exact function/formal/type-hiding guards. Declaration, scalar/initializer and state-bound modules compiled. Fresh focused audits passed for body counts/loop properties (`20261107T193620-fbc422c6bb56`, 9,690 declarations) and declaration source/visibility/formal-frame equations (`20261107T193723-1fb396ba26de`, 16,509 declarations). The [retained packet](evidence/scalar-functions-20261107/README.md) distinguishes these successes from individual objects produced by failed runs. Upper declaration/body correspondence, complete native/Lean checks and independent review remain pending. |
| 2026-11-07 19:47–20:07 | Continuing native/declaration, semantic and body/source streams: GPT-6 Astra / Extra High selected; resumed lead runtime setting not independently exposed | Connect local/formal semantics and recursive call-aware statement source equations | Local declarations and mixed formal analyses passed fresh focused audits; nested body readings/meaning and catalogue-aware recursive native body/helper equations also passed. The [packet](evidence/scalar-functions-20261107/README.md) retains exact run identities and overlapping audit scopes. These changes are integrated through `31f2304225`. Outer adapter/source wiring, complete function/program correspondence, full native/Lean validation and independent review remain pending. |
| 2026-11-07 20:11–20:39 | Continuing native/declaration, semantic and body/source streams: GPT-6 Astra / Extra High selected; named body-equation reduction diagnosis escalated to GPT-6 Astra / Max; runtime settings not independently exposed | Complete source-to-checked-function semantics and connect outer/native helper equations | Native outer adapter and complete accepted function definition/uniqueness passed fresh focused audits, retained in the [packet](evidence/scalar-functions-20261107/README.md); the latter is integrated at `970fe1a263`. Report-policy fixtures passed 39 tests. A broader failed integration check exposed stale inherited equation normalizations and was stopped before more whole-source comparisons once a missing `Function_Body_At` metadata-growth precondition was independently confirmed; existing callers establish that growth. The narrow native contract/caller/source-domain repair is pending, with no change to admitted programs. All-function trace/endpoints, complete native/Lean validation and review remain pending. |
| 2026-11-07 20:45–21:10 | Continuing native/declaration, semantic and report streams: GPT-6 Astra / Extra High selected; resumed lead runtime setting not independently exposed | Complete program consumers and inherited source equations; diagnose remaining native checks | Fresh focused audits passed whole-program grammar (22,602 declarations), assignment/String-bound consumers (23,722), shared source equations and structural guards (38,037), and exact function declaration/body equations and native domains (17,226). Counts overlap; exact runs are retained in the [packet](evidence/scalar-functions-20261107/README.md). The staged body-equation proof now compiles without expanding scanner models. A [bounded static native review](reviews/review-scalar-function-native-admission-20261107.md) found no concrete defect; its two added regression cases await the native workspace lease. The initial report proof finished with seven unproved checks; focused wrapper, cursor, flow and normalization repairs are proved separately, while termination-witness and parser-state equality repairs continue. Concrete source-library wiring, complete checkpoints and delivery review remain pending. |
| 2026-11-07 21:14–22:30 | Continuing native/source streams: GPT-6 Astra / Extra High; named array-equality diagnosis: GPT-6 Astra / Max; independent source review: GPT-6 Astra / Extra High selected; lead runtime setting not independently exposed | Discharge native proof repairs and integrate concrete function source libraries | All seven original report failures now have scoped repair evidence in the [report packet](evidence/scalar-functions-20261107/report-readings/native-repair/README.md). The [parser packet](evidence/scalar-functions-20261107/parser-equality/README.md) records proved metadata equality helpers, the Boolean-array postcondition, array-declaration assertion, function-body postcondition and caller precondition. Shared named type words removed three generated-term differences without changing behavior or contracts. Focused native function source/model audit `20261107T215459-0864d754369b` and named-word model/evaluator audit `20261107T222609-601d7f7b780d` passed; their scopes do not replace a complete checkpoint. |
| 2026-11-07 22:27 onward | Independent review and source repair: GPT-6 Astra / Extra High selected; lead runtime setting not independently exposed | Complete the source-library derivation before final assurance | The [bounded integration review](reviews/review-scalar-function-source-integration-20261107.md) of `2603f6a800` found missing derivations of normalized body/return reader meanings from linked raw source equations. [Finding #340](https://github.com/berkeleynerd/silver/issues/340) tracks the required repair; no false Lean theorem or unsafe admitted program was identified. The failed exploratory source run `20261107T211018-ce0472912f02` was stopped after its diagnosed errors had prepared repairs and pending native changes invalidated further source checks; completed objects remain retained. Native source repairs and source candidates are integrated in the isolated validation worktree while the earlier parser run keeps frozen inputs. Complete validation, final regressions, Rosetta reconciliation and delivery review remain pending. |
| 2026-11-07 22:30–23:10 | Source derivation and independent review: GPT-6 Astra / Extra High; Rosetta/evidence preparation: GPT-6.1 Sol / High selected; lead runtime setting not independently exposed | Finish known parser obligations and raw source-library derivations | All 23 [function behavior tests and the Is_Prime driver](evidence/scalar-functions-20261107/final-native-behavior/README.md) passed. Both condition-reader repairs, including their new assertions and original endpoints, have [focused native evidence](evidence/scalar-functions-20261107/condition-equality/README.md). The [#340 raw source-library repair](evidence/scalar-functions-20261107/focused/20261107T230226-02ff494be2c6/README.md) passed a 49,907-declaration focused audit; independent review and upper integration are pending. Compose equations/legality compile. Retained Sequence failures exposed omitted context equalities and initial empty function metadata; proof-only repairs carry the existing domains. Final source pin/certificate parity passed `20261107T230745-ca313156b33d` after the two Static assertions. The superseded exploratory parser run `20261107T181811-5b7564ac5afc` was deliberately interrupted with its exact source, sessions and failures retained before the mandatory complete native checkpoint. Complete native/Lean assurance, full regressions, Rosetta reconciliation and delivery review remain pending. |
| 2026-11-07 23:10–2026-11-08 00:06 | Native/regression coordination: GPT-6.1 Sol / High; independent repair review: GPT-6 Astra / Extra High selected; delivery coordinator runtime setting not independently exposed | Preserve final native validation and complete upper source integration | The final native build passed and the complete native audit is running. SequenceModel, the full output-source shape pin and inherited catalogue/expression source candidates compiled in focused run `20261107T230910-a15a07ea6dd4`. Its outer scanner equation exposed an omitted function-assignment flag in the Lean expression evaluator/rendering, already present in native `Scan_Step`. The [independent bounded review](reviews/review-scalar-functions-delivery-20261108.md) found no material defect in the prepared three-file source-faithful repair. Productive source chunks and their frozen inputs are retained before applying it. Complete native/Lean checks, full regressions, Rosetta reconciliation and delivery review remain pending. |
| 2026-11-08 | Native/regression coordination: GPT-6.1 Sol / High selected; delivery coordinator runtime setting not independently exposed | Retain complete native outcome and prepare minimal remaining repairs | The [complete native run](evidence/scalar-functions-20261107/native-checkpoint/README.md) discharged all 12,558 checks but failed on three compiler flow warnings; successful full provenance/audit remains absent. The reviewed private-parameter/initializer cleanup is committed in the isolated native worktree for focused flow, build and complete audit refresh. The integration run has compiled all eight output source chunks and Compose source candidates; its output certificate remains active on frozen inputs. Two additional Boolean-context adapter repairs are prepared alongside the reviewed outer repair. Both regression build and full tests await the exact integrated snapshot. No support or merge-readiness claim is made. |
| 2026-11-08 02:15 onward | Native/regression coordination: GPT-6.1 Sol / High; prior bounded review: GPT-6 Astra / Extra High selected; delivery coordinator runtime setting not independently exposed | Integrate reviewed repairs and finish actual-source validation | The frozen source run finished with two known failure groups while compiling its output certificate and downstream source bridges. All five reviewed repairs are applied and compiled. Expanded checking exposed two stale basic/loop candidates and a Boolean proof let binder; three proof-only corrections at `6a74bccc5a` now compile. The named-body candidate remains active, with a later source-bridge layout correction prepared. The [evidence continuation](evidence/scalar-functions-20261107/README.md#expanded-source-check-continuation--2026-11-08) retains failed scopes and pending checks. Full regression build passed and the complete suite is running on its frozen snapshot; complete native/source assurance and final review remain pending. |

The named-body continuation finished with a failed outcome at 03:24 UTC on
2026-11-08. Its [retained diagnostic and repair record](evidence/scalar-functions-20261107/focused/20261108T022400-531d5c89d319/README.md)
identifies the stale header/declaration candidates and source-bridge layout
error, corrected in proof-only commit `f00205b5f8`. Focused checking then resumed
with retained objects. The full regression suite reported errors in its
object-reuse and symlinked temporary-directory platform-routing fixtures;
the completed outcome and exact tracebacks are recorded below. No timeout,
warning policy, domain or required check changed.

The native monitoring handoff did not preserve the active execution as assumed:
run `20261108T014042-81a35c010d1f` is interrupted with no finished event or
successful provenance. Its partial reports and cache were retained before the
identical-option continuation `20261108T040128-2651963b8574`. The
[evidence continuation](evidence/scalar-functions-20261107/README.md#expanded-source-check-continuation--2026-11-08)
records the observation and unconfirmed cause; no source or proof requirement
changed. This interruption is additional rework, not successful validation.

The later [focused source continuation](evidence/scalar-functions-20261107/README.md#successful-focused-source-continuation--2026-11-08)
compiled every named-body extraction, then applied the independently reviewed
wrapper-refinement annotation in `2a3badff5c`. The four-target check passed with
a fresh audit of 449 modules and 113,497 declarations, reusing the retained
source objects. The required complete Lean/source/module/axiom audit has started;
this focused success does not complete native or regression assurance.

The [complete regression packet](evidence/scalar-functions-20261107/final-regression/README.md)
retains 637 methods: 635 passed, two exceeded existing subprocess deadlines,
and none was skipped. All 72 manifest samples passed admission, proof/report
audits, build and expected runtime bytes. The errors were a 60-second initial
proof-object fixture build and a 180-second nested platform-routing fixture;
their causes are not established by the timeout exceptions. The original run
remains failed. Exact final-input, unchanged-deadline focused reruns are queued
after the complete Lean workload releases its workers.

The complete Lean build has exposed a stale Boolean-declaration source
candidate. Its token list omits five hiding checks already present in both the
unchanged native body and its Lean model. The exact candidate-only repair passed
bounded independent static review; the active build retains frozen inputs and
productive source objects. Later memory growth required reviewed, targeted
interruptions of `ComposeExamples` and `FunctionSourceCandidate` while the
other source checks and native proof continued. Both remain required. The
[separately reviewed proof-packaging proposal](reviews/review-scalar-functions-source-packaging-20261108.md)
preserves the function candidate's 80 source requirements and original exported
theorems in independently compiled units. The complete attempt actually exited
at 06:31:02 UTC with only those three known failures; its last expensive source
candidate passed. The [retained failed packet](evidence/scalar-functions-20261107/complete-lean/20261108T044143-17a94f7033eb/README.md)
keeps the completed objects and exact resource actions. Commit `47fe4003c0`
then applied both reviewed repairs byte for byte. Serial leaf, complete
function-source closure and complete project checks remain required. Complete
native/Lean assurance and final delivery review are still pending.

The first object-reuse fixture follow-up repeated its initial-build timeout.
The [isolated configuration, build and import diagnostics](evidence/scalar-functions-20261107/fixture-diagnostics/README.md)
retain exact inputs and measured phase costs. A fresh authenticated local Lean
installation matched every distribution entry; one matched profile reduced
measured import time from 6.87 to 2.91 seconds. The retained comparison records
its cache, scheduling and storage-scope limits. Both regression fixture passes
remain required. Those diagnostics changed no fixture or deadline. The unchanged
local-tool fixture and a final-input symlink fixture both subsequently timed out.
The independent review traced the 60-second build watchdog to the original small
module probes, without a corresponding performance contract. The exact reviewed
repair now gives only the larger certificate fixture's builds 180 seconds;
its audits, all correctness assertions, proof settings and other tests retain
their existing behavior. The complete affected check passed all eleven edit
cases, 25 builds and 12 fresh audits with no errors, skips or input drift.
Four existing source-policy tests also passed against the final module graph.
The separate unchanged platform fixture still failed from a local source root;
its retained partial output exposes inner errors whose exception identities
require diagnosis before any repair. No language rule or proof obligation changed.

The [single concurrent-method diagnostic and watchdog assessment](evidence/scalar-functions-20261107/fixture-diagnostics/README.md)
subsequently established an actual 60-second worker timeout while real source
generation was still progressing. The exact reviewed test-only repair uses
180 seconds for both worker waits and 900 seconds for the complete symlink
wrapper. Every assertion, all twelve nested methods, expected-negative checks
and the fifteen-second barrier remain. One complete affected-fixture check is
authorized; its outcome and final regression applicability review remain pending.
The serial function-source closure and complete native audit continue on frozen
implementation inputs, followed by the mandatory complete Lean/source audit.

The repaired complete platform wrapper subsequently passed with all twelve
nested methods selected, unchanged final inputs and no remaining descendants.
The [independent regression applicability review](evidence/scalar-functions-20261107/final-regression/README.md#accepted-current-input-regression-composition)
now accepts all 637 original test IDs through retained successes and fresh
affected checks, preserving the failed original run. It verifies source, build,
tool and shared-fixture dependencies; no current regression ID is uncovered.
Complete native/Lean assurance remains pending. The later Rosetta promotion
still requires its actual render and three fresh tests, followed by final
delivery review.

The complete native run `20261108T040128-2651963b8574` subsequently failed:
18,520 of 18,524 checks discharged across 77 units, with four unresolved parser
postconditions. The [independent diagnosis](reviews/review-scalar-functions-delivery-20261108.md#four-failed-native-postconditions-independent-diagnosis)
establishes a concrete zero-position `Parameter_Frame` result/model mismatch
and three modular-contract gaps. Its [retained packet](evidence/scalar-functions-20261107/native-checkpoint/four-postcondition-diagnosis/DIAGNOSIS.md)
preserves the source, generated tasks, witness and comparison with earlier
incomplete coverage. The exact entry guard has passed one focused native check;
its source integration and complete assurance remain outstanding. The other
three repairs are being prepared before another complete native run. No input
domain or required postcondition is weakened.

The serial Lean source run retains its frozen inputs and continues compiling
unaffected leaves after a namespace ambiguity in `CallsIncludedImpl`. Its reviewed
qualification repair remains unapplied until the workspace lease is released.
Later native changes require corresponding source and semantic proof review,
regenerated source certificates, complete native/Lean audits and an affected-input
regression review. The accepted regression composition above applies to its exact
unchanged snapshot; it does not pre-accept those future source repairs.

The bounded native repairs are now integrated: the invalid-frame guard, explicit
failed comma/return-token rejection, and successful scalar/Boolean declaration
frame facts. Their exact source and semantic correspondence were independently
reviewed, including the regenerated source certificates and unchanged semantic
models. Focused [semantic closure 091153](evidence/scalar-functions-20261107/focused/20261108T091153-a212a5bfebc3/README.md)
passed both interpretation targets and its fresh 101-module / 16,853-declaration
audit after a retained mechanical unfolding repair. All [six affected native
subprogram checks](evidence/scalar-functions-20261107/native-checkpoint/remaining-three-repairs/README.md)
passed; the ordinary complete native and Lean/source/module/axiom audits remain
active on stable `f630819154` inputs. The rebuilt compiler passed its build.
The [affected regression run](evidence/scalar-functions-20261107/final-regression/repaired-compiler-policy-093645/README.md)
finished with 335 passes and three compile-timeout errors across 338 methods,
without skips. All 72 manifest samples and seven source-policy methods passed.
Exact failed outcomes, diagnostic workspaces and unchanged-input postflight are
retained. The three isolated follow-ups and original platform wrapper will use
the full available host allowance after dense proof runs finish, without changing
deadlines, assertions or proof options. Complete native/Lean assurance and final
regression applicability remain pending; the older 637-ID acceptance has not been
extended to these changed inputs.

Selected subthread settings are recorded from their launches; independent runtime
confirmation, token/cost and total elapsed-work measurements are unavailable.
Native probe time is retained by the managed records rather than inferred from
agent runtime. Complete results and review targets will be recorded here.

## Required assurance chain

The [Oracle](../oracle.md) applies to the entire resulting language and every
permitted composition. Program authors write actual Ada/SPARK and no contracts,
preconditions, postconditions, invariants or proof annotations; the sole
permitted program pragma remains `pragma SPARK_Mode (On);`. Safety must hold
throughout the full call chain for every permitted input and execution path.
Compiler-derived facts must follow from the admitted source and verified
operations, never developer-supplied assurance facts.

Extend decidable membership, typed evaluation, scope/state handling, call/return
composition, universal safety, termination and automatic-discharge arguments.
The result must establish automatic discharge of every required Bronze and
Silver obligation for every admitted program, not merely semantic safety or
successful driver examples. Unknown report entities, new obligation classes or
unclassified diagnostics cannot be accepted as a shortcut. Any new class needs
its semantic/discharge schema and complete producer/provenance account.

Verify all changed Silver-owned SPARK implementation to Bronze and Silver.
Extend the Lean proofs over the actual authoritative compiler/library source,
including source-tree structure and semantic equations affected by function
parsing, binding, analysis and report selection. Review source pins with the
source and semantic changes. A separately correct call model or refreshed pin
does not establish actual-source correspondence. Author source admitted,
proved and compiled must remain byte-identical; hidden annotated replacements,
source rewriting to ease proof and narrowed input domains are forbidden.
Keep [assurance claims](assurance.md) and
[trusted assumptions](trusted-boundary.md) precise.

## Validation and completion criteria

Use focused native probes and Lean targets while settling the mechanism, then
complete the native Bronze/Silver, ordinary build, complete Lean/actual-source
and fresh module/axiom audit checkpoint on stable implementation inputs. Read
the managed-run summary first, retain successful matching evidence, and record
the input/configuration comparison that makes reuse applicable. Follow the
[proof-iteration workflow](proof-iteration.md), actual workspace/worker
reservations and documented CPU/memory settings; avoid identical-success
expensive reruns without a stated reason. Linux evidence is primary; independent
macOS validation remains nonblocking. No native, Lean or sample result is claimed
by this planning record.

Exercise the driver through admission, proof, build and execution with independent
expected results. Cover type/domain boundaries, scope and hiding, returns and
rejected missing returns, direct/indirect recursion rejection, call compositions,
no-mutation/effect restrictions, dead code and interactions with the existing
scalar, guard, loop and array language as applicable. Include source/storage and
report-capacity boundary evidence for the chosen rules. Complete proportionate
regression validation, identifying fresh runs and retained applicable results
separately; samples do not replace the universal assurance argument.

At delivery, update `language.md`, the catalogue, samples, roadmap capability
status and this record together. Reconcile the precise Rosetta construct
identifier/assessments with the delivered fragment, update the assessor's
current-language description, render the progression and reconcile affected
stage issues under [Rosetta progression](planning.md#rosetta-progression).
Do not promote broad functions/procedures or promise coverage totals ahead of
that review. Publish the reviewable implementation and evidence for independent
review; retain #298's open status until the complete package and later authorized
merge close it.

## Planning settings

Documentation preparation selected GPT-6.1 Sol / High; independent runtime
confirmation, token/cost measurements and elapsed-work measurements are
unavailable. This planning subthread performs no proof/build/test/render run,
GitHub mutation, staging, commit or publication. The lead integrates and
publishes the bounded plan before implementation.
