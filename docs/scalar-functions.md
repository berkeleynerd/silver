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
The sources, reports and managed records currently reside in the planning
worktree's `tmp/native-function-probes/`; retain the delivery-relevant evidence
in the checked-in packet before support is claimed. The integration installation
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
