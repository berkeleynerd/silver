# Bounded library packages and application units

Current status, 2026-11-27 21:43 UTC: PR #424 remains draft. Both namespace
repairs pass their focused behavior checks. Specification, static Boolean,
Charge_Unit, Object frame preservation and the Unit/Main import increments have
focused proof evidence; their final original-bundle composition is unfinished.
The authoritative source batch is reconciling an old whole-file pin with the
expanded source. Native containing-unit coverage remains running with three
interim array-helper timeouts awaiting final report classification. Complete
native/Lean assurance, regression/Rosetta delivery and closing review remain open.

## Selection — 2026-11-22

The owner selected [#416](https://github.com/berkeleynerd/silver/issues/416)
after PR #412 merged, together with the upfront runtime/profile feasibility
part of [#421](https://github.com/berkeleynerd/silver/issues/421). The
[authorization](session-memory.md#2026-11-22--bounded-packages-and-ravenscar-feasibility-authorized)
also requires relevant newly enabled Rosetta samples with each language feature.
This record describes work in progress, not currently admitted syntax.
The broader [Ravenscar plan](ravenscar-tasking-plan.md) supplies the ordering;
protected objects, tasks, entries and clock operations are later increments.

## Selected first fragment

One application library package has a specification and body, alongside Main.
Their original files remain the inputs to proof and compilation. Select one
static dependency from Main to that package, with no cycles, package renaming,
child/nested/generic packages or dependency search framework. All three original
files together must fit the existing 4,096-byte source allowance. Source-wide
arithmetic/concatenation operators share the existing 63-operator budget across
the units; each unit's comments and strings are lexed independently. Per-expression
limits remain unchanged. These bounds retain the existing bounded proof-cost and
storage foundation; multiple files do not multiply that allowance.

The intended package exports scalar subtype/constant declarations and scalar
function/procedure signatures. At least one routine signature requires its body
under Ada's rules; the author pragma `Elaborate_Body` is not admitted. Its body contains explicitly initialized private
Integer/Boolean state and matching routine completions in declaration order.
Bodies use the established scalar statement, guard and finite-loop forms, with
calls only to already completed routines. Zero-formal package operations support
ordinary state accessors and updates without dummy parameters. Package functions
may read state; procedures may update it. Inputs and state are checked over their
full declared domains, including unused routines. Main uses qualified exported
names and calls. Existing single-unit programs retain their rules.

The first fragment excludes private types/parts, package arrays, extra private
helper routines, executable package-body elaboration statements and package I/O.
These are bounded implementation choices, not Ada restrictions. Main retains the
existing I/O and argument facilities. Package calls from existing closed Main-local
callables are not part of the selected first fragment. Those closed routines may
use qualified exported subtype marks but cannot read package constant values.
Their existing initializer proof starts from empty value tables; admitting those
reads would need a separate source-bound constant-freezing and slot-mapping
argument. Main itself and package routines may use public constants. This keeps
the package state/call integration within the selected capability rather than
expanding the old closed-initializer mechanism. Exact spelling, visibility,
elaboration, call aliasing and effect rules must be reflected together in the
language, catalogue, native recognizer and source-bound proofs before support is
claimed.

## Source, state and assurance design

Store the exact specification, body and Main bytes in one bounded pool, with
half-open contiguous unit spans. Parse each unit only through its own end, so
an end-of-file comment cannot swallow the next unit. Earlier declaration names
retain their original byte positions. Snapshot each original slice separately;
never compile or prove a flattened or annotated replacement program.

Use package-specific signature/effect metadata. Hidden captures must not consume
the existing source-derived explicit-formal pool: a routine can access several
state objects whose declarations occur only once. Derive transitive read/write
sets in body completion order. Check explicit and implicit writable aliases,
retain read-only state facts where justified, and invalidate written state facts
at calls. Full declared global/formal domains govern body admission; initial
example values cannot justify later arithmetic.

The proposed mathematical integration represents captured state as implicit
scalar inputs/results in the existing callable model. This is an internal model
transformation, not a source rewrite. Its equivalence to shared package-state
execution must be proved over statements and earlier calls, then connected to
the actual source recognizer. Existing scalar safety/discharge lemmas can be
reused only after that correspondence is established. The application endpoint
must cover the complete selected source-unit set, elaboration and every required
unit/entity report. A Main-only audit cannot establish package assurance.

## Drivers and Rosetta delivery

The [task/source assessment](../rosetta/assessment-bounded-packages-20261122.md)
selects **Include a file** and **Queue/Definition** as newly enabled tasks.
Include a file requires source inclusion from another file; it does not require
package I/O or a zero-argument interface. Use a package exporting a bounded
scalar calculation, then call it and print the result from Main. Retain and check
all three source files, the complete report set, and expected output.
The queue demonstrates FIFO push/pop/empty using two private scalar cells,
with explicit full and empty outcomes. It stays within the scalar-package
fragment without arrays or private types. A separate small counter exercises
hidden state, reset/getter operations and repeated calls with different state values.

[Stage issue #425](https://github.com/berkeleynerd/silver/issues/425) tracks the
precise Rosetta fragment and delivery bookkeeping. It remains In progress, with
the generated Stage pending the first render of this identifier.

Use the precise candidate identifier `bounded-library-packages`. The broad
`packages` identifier also covers private types and remains unsupported.
**Return multiple values** and **Primality by trial division** are possible
package-interface rewrites of already supported tasks, not new task gains.
**Modulinos**, **Executable library** and **Singleton** are not promised by this
increment; their direct-execution, library reuse or class/instance requirements
need separate faithful assessments. Preserve prior review provenance when changing
existing task mappings.

At delivery, add the actual runnable samples, update the affected assessments,
current-language rubric, catalogue and supported identifier, render Rosetta,
and reconcile stage fields. Record the actual new mapping count, not a speculative
gain. Samples exercise the universal argument; they do not replace it.

## Checks and integration

Before the shared complete checkpoint, establish canonical focused success for
every new/changed native helper's full contract and affected callers/callees,
and the relevant Lean source/semantic targets. Check negative unit-name/body
matching, missing/extra files, cross-unit visibility, uninitialized state,
recursion/forward calls, aliasing, source/operator boundaries, end-of-file comments
and byte-identical original-unit snapshots. Include full-domain package state,
unused routines and compositions with existing Main forms.

Use one stable complete native/Lean/source checkpoint and complete applicable
regression/sample coverage, with independent critical proof and implementation
review. Preserve failed attempts and reuse matching successes under development.md.
No new scheduler, mandatory cold rebuild, kernel replay or binary-attestation
framework is selected. The host has eight CPUs shared by all managed work;
all worker counts and thread/child affinity must respect that allocation.

## Initial rounds

| Round | Selected settings | Outcome and next check |
| --- | --- | --- |
| Scope/source architecture | GPT-6 Astra Max | Exact original-unit packing and package-state model strategy identified. Native/source/semantic implementation and complete validation remain outstanding. |
| Rosetta inventory | GPT-6.1 Sol Extra High | Include a file is a faithful first gain; broader package/private-type and executable-library claims excluded. No support promotion yet. |
| Pinned runtime and state feasibility | GPT-6 Astra Max | Exploratory hidden/visible package state, including zero-formal operations and a no-inlining composition control, prove without author contracts. A minimal protected/task program proves/builds/runs under profile configuration. The unprivileged host's observed scheduler is not real-time FIFO; retain the separate runtime qualification for later #421 delivery. Exact producer evidence and limitations are retained in the [feasibility packet](evidence/ravenscar-feasibility-421-20261122/README.md). |
| Exact source-bundle helper | Contract design GPT-6 Astra Max; implementation GPT-6.1 Sol Extra High | `c84b73b6ba`; canonical focused run `20261122T125009-00cc034988d0` passed all 81 checks (12 flow, 69 proof), eight workers, 10.422 s. [Packet](evidence/bounded-library-packages-416-20261122/source-bundle/README.md). New parser/driver callers and complete assurance remain outstanding. |
| Initial package semantics and zero-formal integration | GPT-6 Astra Max | Four new foundation modules passed run `20261122T130212-b9742bea2354` (5,927 declarations); zero-formal semantic generalization and six affected consumers passed `20261122T131112-bc4a3d4bb2bc` (26,028 declarations), automatic eight workers/threads. [Packet](evidence/bounded-library-packages-416-20261122/semantic-foundations/README.md). Native-reader/source/whole-bundle integration remains outstanding. |
| Package shared-state and capture equivalence | GPT-6 Astra Max | Four further focused checks establish slot reindexing, whole-body locality, constructed earlier-callee locality, and exact capture/shared-state output equality. Final focused run `20261122T134832-ecd089d7673d` audited 21,867 declarations in 15.717 s with cached dependencies. The [same packet](evidence/bounded-library-packages-416-20261122/semantic-foundations/README.md) retains all four results. Native effects/maps, automatic-discharge and source endpoint integration remain outstanding. |
| Original-unit parser and samples | Lead integration GPT-6 Astra Extra High; native/source design GPT-6 Astra Max | All 26 package regression methods passed in `20261122T150042-fa61acf6b4e2`. The [three compiled samples](evidence/bounded-library-packages-416-20261122/initial-samples/README.md) passed admission, audit, build, exact original-source checks and expected output. The explicit `GNAT` identity exclusion follows an observed pinned-producer exception; `Standard` remains allowed after a full compile/audit/run control. Complete feature assurance remains pending. |
| Storage, metadata and shared context proofs | GPT-6 Astra Max | Exact original-unit storage and metadata source bridges passed focused checks; sequential initializer safety passed `20261122T150634-006e0b3e49c0`. Generalizing qualified bindings exposed old constructor arities in retained callers; those repairs and the complete package/Main composition endpoint remain in focused integration. No complete native or Lean checkpoint is claimed. |
| Rosetta task/source reconciliation | Lead role: GPT-6 Astra Extra High | Reread Include a file, Modulinos, Executable library and Singleton requirements. Prepared two new mappings and a separate stateful driver; no broader task-support claim. Sample execution and feature delivery checks remain pending. |
| Qualified inherited parser and source helpers | Source correspondence GPT-6 Astra Max; lead integration under the repository lead/proof guidance | The scalar expression actual-source closure passed `20261122T161157-4d9d5a172c67` (17,649 declarations); the shared qualified subtype/context helpers passed `20261122T161856-e778d3883fb9` (19,664). The retained [scalar](evidence/bounded-library-packages-416-20261122/scalar-source-closure/README.md) and [Compose](evidence/bounded-library-packages-416-20261122/compose-qualified-context/README.md) packets distinguish source checks from model-only checks. Qualified Predicate models also passed their [focused check](evidence/bounded-library-packages-416-20261122/predicate-qualified-model/README.md). Complete application source integration remains pending. |
| Full-domain package body, routine and library safety | GPT-6 Astra Max | Five focused checkpoints establish call and loop composition, body safety, initialized routine safety and completion-order library safety including unused routines. The [semantic packet](evidence/bounded-library-packages-416-20261122/package-semantics/README.md) retains all actual inputs, runs and axioms. The library fold passed `20261122T162059-cfa96b788a96` (23,559 declarations). Main and native source correspondence are still required. |
| Native package-specification contract diagnosis | GPT-6 Astra Max | Run `20261122T154517-101a5dc5fa74` failed after 2,235.074 s at one postcondition and eight preconditions. The package loop needs explicit preservation of cursor/state validity; its signature callee must export the successful stored-name fact used by the caller. The failed report and input set remain in the managed ledger. Next: complete the smallest changed helper contracts, then the caller. This is development failure evidence, not a completed native checkpoint. |
| Whole Main/package execution | GPT-6 Astra Max | The [Main semantic checkpoints](evidence/bounded-library-packages-416-20261122/package-semantics/README.md) establish exact callable translation, shared-state execution and automatic obligation discharge across the existing Main forms. The final semantic focus `20261122T163552-8721ebca3536` audited 23,824 declarations. Original-Bundle/native-reader correspondence remains required. |
| Typed package source foundations | GPT-6 Astra Max | The [shared core](evidence/bounded-library-packages-416-20261122/shared-native-core/README.md), [original-unit value extension](evidence/bounded-library-packages-416-20261122/shared-native-core/application-values/README.md), [frame trees and compaction](evidence/bounded-library-packages-416-20261122/package-frame-trees/README.md), and [static Boolean primary/factor](evidence/bounded-library-packages-416-20261122/static-boolean-typed/README.md) passed focused builds and fresh audits. These establish typed evaluators, structural checks and selected model equations; full actual-source links remain pending. |
| Native signature preservation diagnosis | GPT-6 Astra Max | Run `20261122T163400-329302598e53` proved 64 of 66 checks (14 flow, 50 proof), leaving two unchanged-state preservation obligations after 968.467 s. The helper postcondition now explicitly preserves unaffected frame components without narrowing its entry domain. The complete Append focus `20261122T165616-d68c94f0ca7f` passed all nine checks; the dependent Signature retry is running. |
| Frame interpretation and original-unit Main reader | Continuing proof-role work; runtime settings not independently exposed | The [initial frame interpretation](evidence/bounded-library-packages-416-20261122/package-frame-trees/interpretation/README.md) passed `20261122T172323-bcaf69dc0b74` (21,864 declarations). It proves local update/loop facts and the scalar qualification body; complete frame/source binding remains pending. The separately checked raw Main reader preserves the original context, completion/EOF guards and declaration tables. Native Signature retry `20261122T165753-f61735da6ae4` still timed out on two validity obligations, without a countermodel; its complete diagnostic check retains the original domain and adds checked assertions. Count growth in the declaration source model also requires an explicit storage-projection argument before source correspondence can close. No complete validation checkpoint is claimed. |

Runtime-confirmed agent settings and whole-team token/cost measurements are not
independently exposed. These exploratory results are not final compiler assurance.

## Continuing source integration — 2026-11-22

The complete Signature helper now passes all 77 checks in
`20261122T172039-c364b0adf1b1`. Six proved intermediate validity assertions retain
the facts that the solvers previously lost; entry domains and the full invariant
are unchanged. Further focused checks cover the name/type helpers, Hide_Outer,
and all four static Boolean readers. The last Boolean reader needed a two-line
control repair: its invariant `while` condition became an unconditional loop,
using the existing internal return when no operator remains. Its complete
22-check native validation and matching model/source-tree check are retained in
the [native packet](evidence/bounded-library-packages-416-20261122/native-package-contracts/README.md)
and [Boolean loop packet](evidence/bounded-library-packages-416-20261122/static-unconditional-loop/README.md).

| Round | Selected settings | Outcome and next check |
| --- | --- | --- |
| Main source interpretation and package control | Architecture subthread: GPT-6 Astra Max | The exact typed Main reader, its proposed source-token match, and raw completion/unit control passed [focused checks](evidence/bounded-library-packages-416-20261122/package-completion-unit/README.md). Typed procedure control also passed its [own check](evidence/bounded-library-packages-416-20261122/package-procedure-control/README.md). Complete package-body decoding and original-source integration remain pending. |
| Native declaration representation | Source subthread: GPT-6 Astra Max | The [shared declaration API](evidence/bounded-library-packages-416-20261122/package-source-core/declaration-api/README.md) preserves arbitrary uninitialized scalar values and the actual partial defaults of native records. The count-growth projection is proved against arbitrary full storage. These foundations still need their source-bound declaration/body uses. |
| State effects and frame qualification | Continuing lead proof work; runtime settings not independently exposed | The [state-effect equations](evidence/bounded-library-packages-416-20261122/state-effects-model/README.md), all three [frame qualification loops and effect trees](evidence/bounded-library-packages-416-20261122/frame-loops-effect-trees/README.md) passed focused checks. A whole-frame normalization attempt grew to approximately 24 GiB observed RSS and was interrupted; its next proof composes intermediate-state equalities. The successful smaller results are retained. |
| Complete imported frame and state-effect interpretation | Continuing lead proof work; runtime settings not independently exposed | The split [Imported_Frame proof](evidence/bounded-library-packages-416-20261122/package-frame-trees/imported-frame/README.md) passed its complete body equation without narrowing the domain. The [state-effect and shadow checkpoint](evidence/bounded-library-packages-416-20261122/effects-and-shadow-interpretation/README.md) passed 21,842 declarations, including complete visibility, target and read-set equations and their exact native header/body token proposal. It also checks the generic shadow compaction loop and scalar filter step. Whole Hide_Outer and the authoritative complete-source witnesses remain pending. A prior run failed input provenance after an unrelated proof edit; its failure is retained and the successful replacement froze the full captured inventory. |
| Complete object/specification and effect helper contracts | Native subthread: GPT-6 Astra Max | Package_Object_At passed 28 checks, Package_Spec_At 43, and the visibility/target/read-set/callee helpers 12/10/10/11, respectively. The [native packet](evidence/bounded-library-packages-416-20261122/native-package-contracts/README.md) records the exact source identities and remaining helper/caller gates. These are focused results, not a complete compiler audit. |
| Call alias effects and procedure source interpretation | Native and architecture subthreads: GPT-6 Astra Max | The [call effect equations](evidence/bounded-library-packages-416-20261122/package-call-effects/README.md) derive the accepted alias exclusions and final effect unions. The [Unit step checkpoint](evidence/bounded-library-packages-416-20261122/package-unit-step-interpretation/README.md) verifies loop-body equations and procedure control laws. Exact [call](evidence/bounded-library-packages-416-20261122/package-call-source-candidate/README.md) and [completion/unit](evidence/bounded-library-packages-416-20261122/package-procedure-source/README.md) token proposals also pass. Whole procedure interpretation and original-bundle decoding remain open. |


| Whole shadow-frame model and alias passes | Continuing lead proof work and native subthread GPT-6 Astra Max; live lead runtime settings not independently exposed | The [complete Hide_Outer model](evidence/bounded-library-packages-416-20261122/shadow-frame-model/README.md) passed 21,761 declarations, composing all three compaction loops with the full model. The [alias passes](evidence/bounded-library-packages-416-20261122/call-alias-fold/README.md) include full formal-loop interpretation and preservation of later inputs. Authoritative source binding and caller semantics remain required. |
| Whole Unit interpretation and Completion phases | Architecture subthread GPT-6 Astra Max | Whole Unit typed execution and its phased-model refinement passed. Completion's [local/output-append steps](evidence/bounded-library-packages-416-20261122/package-completion-steps/README.md) and [output-read block](evidence/bounded-library-packages-416-20261122/package-completion-read/README.md) passed fresh audits, including exact scope restoration. Complete Completion and original-bundle decoding remain open. |
| Native call and frame diagnostic, 19:07 UTC | Native subthread GPT-6 Astra Max | The full Package_Call_At focus finished with cursor/span/index proof failures and an overwritten-initializer diagnostic. The next repair strengthens executable guards and preserved loop facts without narrowing its entry domain. Inspection also found that Routine_Frame could read an inactive metadata entry under its declared precondition; an explicit active-count guard is being added within this delivery. These findings block complete validation. |


| Repaired complete native call contract, 19:28 UTC | Native subthread GPT-6 Astra Max | Canonical focused run `20261122T191156-df67d2d4c1c4` passed all 85 checks (13 flow, 72 proof), with no unproved/skipped obligations, in 917.314 seconds at two workers. The [native packet](evidence/bounded-library-packages-416-20261122/native-package-contracts/README.md) retains the failed predecessor and successful guarded repair on source hash `c37214cd9bc8772c84b2f4cd775d6582748e4499f829bf282bfe81e1264871af`. Routine_Frame, Completion, Body and remaining caller gates are still required before complete native validation. |

All of these are development checkpoints. The remaining native helper/caller
contracts, whole-reader source correspondence, complete validation, final Rosetta
promotion and independent delivery review still block a support/completion claim.

## Resumed integration — 2026-11-27

After the host returned, all managed runs were reconciled with their retained
outcomes before launching further checks. The host detects eight CPUs, with
allowed guest CPU IDs 0–7. Three source/native proof subthreads selected
GPT-6 Astra Max; each uses at most one two-worker allocation while the lead
uses the remaining two workers. Observed worker-thread affinities stayed within
those reserved CPU sets. Runtime-confirmed model/effort are not independently
exposed. The elapsed calendar gap is not proof execution time.

| Round | Result and remaining scope |
| --- | --- |
| Whole Object and routine-frame interpretation | The retained [Object execution](evidence/bounded-library-packages-416-20261122/package-source-core/object-equations/README.md) passed 20,957 declarations. The new [whole Routine_Frame interpretation](evidence/bounded-library-packages-416-20261122/package-routine-frame-meaning/README.md) passed 20,980, including the guarded inactive metadata case and current invariant syntax. Full declaration/statement/bundle integration remains open. |
| State validity and effects | [Focused support closure](evidence/bounded-library-packages-416-20261122/support-domain-closure/README.md) passed 29,517 declarations. Six exact proposed table expressions, full imported metadata domains and guarded effect lookup domains are proved. The packet discloses the copied cache seed; authoritative profile binding and effect-callee wiring remain required. |
| Native helper contracts | The [native packet](evidence/bounded-library-packages-416-20261122/native-package-contracts/README.md) now retains Application_Basic's 47-check success and new complete Routine_Frame and Application_Tail successes of 22 and 25 checks. The changed existing-helper inventory also identifies affected callers. Remaining helpers/callers must pass before the integrated native checkpoint. |
| Completion loops | The [local/output simulations](evidence/bounded-library-packages-416-20261122/package-completion-loop-simulation/README.md) passed a fresh 20,906-declaration audit, including arbitrary stores and fuel exhaustion. Whole entry/footer and semantic integration continue. |
| Certificate build diagnosis | The [flat-token diagnostic](evidence/bounded-library-packages-416-20261122/certificate-token-depth/README.md) reproduces the prior recursion-depth failure and passes with a declaration-local size-based budget. Only OutputBody's generated declaration setting changes. This is not a complete certificate or feature audit. |

No new support or final completion claim is made by these focused checkpoints.
The original three samples and their planned Rosetta mappings remain part of
the delivery, with final validation, rendering and support promotion pending.

### Imported helpers and statement integration, 12:57 UTC

The [primitive source check](evidence/bounded-library-packages-416-20261122/state-primitive-source/README.md)
now connects the state-validity aggregate to its actual name-state and six table
implementations. The [frame import check](evidence/bounded-library-packages-416-20261122/frame-primitive-imports/README.md)
connects the complete Imported_Frame tree to those callees and establishes that
qualification preserves their native metadata representation domains. The
[complete shadow-frame interpretation](evidence/bounded-library-packages-416-20261122/hide-complete-imports/README.md)
then checks all three compaction loops against concrete lexical/package-name,
visibility and validity helpers. Its fresh audit covers 44,395 declarations;
original-profile source binding and the complete application endpoint remain
separate unfinished requirements. An inherited local scalar-binding constructor
also needed the two zero qualification defaults introduced by the package fields;
its focused check now passes.

The [complete call proposal and flow domains](evidence/bounded-library-packages-416-20261122/call-actual-stages-validity/README.md),
[application-tail interpretation](evidence/bounded-library-packages-416-20261122/package-tail-meaning/README.md)
and [statement conditional arms](evidence/bounded-library-packages-416-20261122/package-statement-arms/index.json)
have passed focused checks. Both Statement headers and its full 2,139-token
fragment also passed their [source proposal check](evidence/bounded-library-packages-416-20261122/package-statement-source/index.json).
These do not establish the remaining complete Statement and original-bundle
semantic connection.

Native Statement run `20261127T121829-562685cbce5e` finished with one unproved
Application_Tail precondition after constructing a counted-loop inner flow,
at line 9134 of source `2e055cec`. It ran for 2,082.160 seconds; the failed
outcome remains failed and is under focused diagnosis. At that source boundary,
the prepared Object initializer-bound postconditions, Completion progress
postcondition, preserved validity invariants and explicit final frame-validity
guard were integrated as `8e766b6712`, source `d3103d20`. Their affected native
helper/caller checks and exact source-tree updates precede complete validation.

A separate Signature source comparison was interrupted after observed RSS
reached about 40.6 GiB. Its already-checked dependencies remain reusable; the
next attempt splits the header and rendered body equalities into smaller kernel
checks. The host's eight-CPU allocation is unchanged, with managed worker and
thread affinity confined to guest CPUs 0–7. No complete native/Lean checkpoint,
final Rosetta promotion, independent delivery review or merge is claimed.


### Declaration source checks and effect identity, 13:25 UTC

The [split Signature check](evidence/bounded-library-packages-416-20261122/package-source-core/declaration-source/README.md)
now passes all 1,536 body tokens, complete headers/defaults and typed rendering
under an 8,192 MiB Lean threshold. Its sampled high-water mark was about 6.8 GiB;
the earlier interrupted monolithic attempt remains recorded. The
[declaration execution checks](evidence/bounded-library-packages-416-20261122/package-source-core/declaration-procedures/README.md)
also establish termination of both declaration readers on their full domains.
Typed loop simulations and authoritative whole-profile binding remain separate.
The [updated Statement source check](evidence/bounded-library-packages-416-20261122/package-statement-assertions-and-headers/index.json)
covers the current static assertions and counted/array loop headers; its complete
statement interpretation is still being composed.

The [source-expression effect bridge](evidence/bounded-library-packages-416-20261122/expression-effect-identity/README.md)
passed a fresh 26,906-declaration focused audit. It connects a bare Integer
identifier's actual frame slot and original declaration span to the corresponding
package-state read bit and semantic cell. This does not yet cover every compound
or qualified expression. The next focused work updates inherited name-reading
proofs for qualified references and extends that bridge before final integration.
The three proof subthreads continue at selected Astra Max; live runtime settings
are not independently exposed. Native Statement and remaining helper/caller
checks, the complete application endpoint, delivery validation and independent
review remain outstanding.


### Complete Statement, Specification and expression-effect integration, 13:46 UTC

The complete Statement interpreter is integrated at `e79efc8b1d`: its typed
execution matches the raw reader for arbitrary incoming stores and fuel,
alongside the current source-fragment comparison. The accepted Tail delimiter
and progress facts and whole ordinal actual-argument step followed at
`67834cd16e` and `42e43d9fa4`.

The [Specification simulation](evidence/bounded-library-packages-416-20261122/package-source-core/declaration-simulation/README.md)
now covers its full entry, all declaration branches, loop and finish behavior
for arbitrary stores, including partial updates on rejection. The same focus
checks the native Function_Type_At import and five affected inherited
context/type-domain proofs (45,555 declarations). Full Signature simulation and
the original-bundle semantic decoding remain separate work.

The [complete expression/condition effect checkpoint](evidence/bounded-library-packages-416-20261122/condition-state-effects/README.md)
passed 27,943 declarations. It derives package-state read bits from actual frame
lookups and preserved declaration spans for complete scalar expressions and
Integer/Boolean conditions. Inherited lexical proofs now retain qualified names
and arbitrary source-unit contexts. The final source decoder still has to supply
the native-frame-to-state layout; these results do not assume or establish the
whole-language endpoint by themselves.

Native Statement retry `20261127T130601-2687d262ec8e` remains failed after
2,067.697 seconds: 11 flow checks and 139 proof checks passed, with one remaining
Application_Tail precondition at line 9149. The newly added full Valid_Flow
assertion immediately before that call passed. The retained task combines the
body and context preconditions; diagnosis is isolating its remaining component
before another attempt. No input domain has been narrowed or failure relabelled.

All three source/native subthreads continue under selected Astra Max settings,
with actual runtime model/effort not independently exposed. The host detects
eight CPUs; observed proof threads remain within their reserved subsets of guest
CPUs 0–7. Remaining native helpers/callers, original-source and semantic closure,
complete validation, final Rosetta promotion and independent review are still
required. PR #424 remains draft; no merge or new language support is claimed.


### Original declaration identities and source-derived read effects, 14:18 UTC

The [scalar source identity](evidence/bounded-library-packages-416-20261122/scalar-source-identity/README.md),
[condition source identity](evidence/bounded-library-packages-416-20261122/condition-source-identity/README.md)
and [layout-effect bridge](evidence/bounded-library-packages-416-20261122/layout-state-effects/aggregate/README.md)
passed focused Linux checks and fresh axiom audits. Original-name lookup now
follows from the parsed expression, including Boolean scalar-shadow exclusion
and scalar flow overlays. The concrete source-span layout supplies the global
state identity, kind and original spans; the full condition read set maps into
the native State_Reads mask. These are parts of the final decoder, not an
assumed whole-language correspondence. Declaration source histories, original
Object rows and formal-order argument reads are integrated at `470f594d0b`,
`27b5959877` and `bbac3feb1b`.

The complete typed Signature and canonical declaration-reader executions passed
with the 1,536-token source candidate (`b791967b79`). The native flow-legality
repair freezes the two mutable constraint inputs before object declaration
(`e2470b6e98`); its Completion interpretation and 2,786-token combined fragment
check passed at `e8bf096bd0`. No native input domain or source capability changed.

The source-isolated Statement diagnostic
`20261127T135353-ae9ac5772cde` proved all ten selected checks, including the four
separated context/body facts and recursive Application_Tail precondition. Its
four static assertions are integrated at `666ba80937`; the canonical complete
Statement helper check `20261127T141021-61ebae4a0685` is running. The diagnostic
is experimental and does not replace that whole-helper gate. The earlier
complete failure remains failed.

The lead integrated the separable subthread results and continues the original
Imported_Package source interpretation and authoritative support binding. The
three proof/contract subthreads retain selected Astra Max settings; the live
lead's model/effort is not independently exposed. Host detection reports eight
CPUs, and inspected native threads have their reserved affinity within guest
CPUs 0–7. Final semantic/source closure, remaining native helper/caller gates,
complete checkpoints, Rosetta delivery and independent review remain pending.
PR #424 remains draft and is not ready to merge.

### Concrete shared-frame context and declaration storage, 14:36 UTC

The [layout/context and import-source focus](evidence/bounded-library-packages-416-20261122/layout-context-import-source/README.md)
passed its fresh 28,830-declaration audit and is integrated at `09de0d2309`.
The concrete layout now supplies every `FrameLayout.Context` field for the
actual parser analysis, including its array overlay. Its source-history premises
are explicit: row validity, capacity, body widening and preservation of global
rows' declared domains and mutability. The final source decoder must still
establish those premises. Imported_Package's complete typed fragment matches
its original header and all 475 body tokens, with scope and precedence checks;
its full execution/domain proof and authoritative aggregate binding remain pending.

Checked declaration work now includes original Object cursor extents
(`af98766b11`), complete retained/installed storage through Hide_Outer
(`caeac4162d`), and function input modes derived from the Signature rejection
arm through Specification and completion (`7b1301a96e`). These are source-derived
facts, not extra assumptions about accepted metadata. Their evidence remains
in the corresponding package-object and declaration-simulation packets.

The canonical complete Statement helper gate remains running on the frozen Ada
inputs. The three proof subthreads retain selected Astra Max settings; routine
monitoring does not change those live selections. Managed reservations and
inspected thread affinities remain within the eight-CPU allocation (guest 0–7).
The original-bundle endpoint, outstanding native/callee gates, complete assurance,
regressions, Rosetta promotion and independent review still block delivery.
PR #424 remains draft, with no new support or merge-readiness claim.

### Complete Statement helper success and call semantics, 14:51 UTC

Canonical whole-helper run `20261127T141021-61ebae4a0685` passed all **158**
Application_Statement checks (11 flow and 147 proof) in 1,813.670 seconds on
Ada digest `95c0f3b33e522adb0bec348520b196a51d8d700ef5bae754056f247fa83c9b09`.
The [native contract packet](evidence/bounded-library-packages-416-20261122/native-package-contracts/README.md)
and coverage inventory retain the reports, unchanged canonical policy, earlier
failed runs and focused repair diagnosis. This is the complete helper gate,
not a complete compiler audit. The same frozen source is now undergoing the
Package_Completion_At helper check `20261127T144204-d3e112615a84`.

The six call modules in `2a7a67e071` passed their fresh 31,697-declaration audit:
actual-source alias exclusion, function input-mode checking, procedure
copy-in/copy-out checking, and native entry/read/post-actual phases. Original
StateFrame rows now supply the complete contextOf layout invariant
(`5fd88d018f`), and both formal installation passes have exact native storage
and cursor laws (`5acf011ad1`). Declaration callee/type-domain work is integrated
at `208ab5de9d`; the remaining call sites and whole-bundle decoder remain open.

The [import inner-iteration packet](evidence/bounded-library-packages-416-20261122/imported-package/inner/README.md)
records its fresh 21,192-declaration audit and rechecked complete source tree.
The proof covers arbitrary local stores/callees and every iteration exit,
restoring temporary names while retaining cursor writes. Source semantics are
being composed through both loops; this does not yet establish the whole helper
or its final authoritative binding.

All source/proof streams remain active under the shared eight-CPU ceiling;
no Ada source was changed during either native run. Complete assurance,
regression/Rosetta closeout and independent review remain required. PR #424
remains draft and is not ready to merge.

### Complete call and completion/body helper checks, 15:07 UTC

The whole typed `Package_Call_At` body now implements its staged call model for
arbitrary scratch storage and the native parameter-table capacity. The
[call-denotation evidence](evidence/bounded-library-packages-416-20261122/call-actual-stages-validity/README.md)
records `20261127T145532-5bc438212097` and its fresh 21,239-declaration audit;
integration commit `8b16e6f121` retains the complete source-header/body implication.
This does not yet close all imported callee meanings or the whole application.

Canonical focused native checks on the same `95c0f3b3` source passed
`Package_Completion_At` (59 checks, 1,093.308 seconds) and `Package_Body_At`
(36 checks, 184.576 seconds). The
[native packet](evidence/bounded-library-packages-416-20261122/native-package-contracts/README.md)
retains their full reports and current coverage inventory. No obligation was
skipped, and the source remained unchanged during both runs. Imported_Frame,
the remaining application helpers and affected inherited callers still require
their focused checks before a complete compiler checkpoint.

The ordered formal-body spans now derive from the actual successful completing
Signature (`bf77ae5cdf`), including zero-formal progress and state-table retention.
The final mixed-order frame (`24aef54266`) and accepted Completion-body layout
(`ff3a99823e`) derive the original storage used by local declarations and delayed
output-formal initialization. The complete import-scanner execution/model
equality also passed in `11714bf8df`; its
[loop packet](evidence/bounded-library-packages-416-20261122/imported-package/loops/README.md)
separates that result from the real-callee, termination and authoritative-source
connections still being integrated.

The three proof subthreads retain their selected GPT-6 Astra Max settings;
runtime model/effort is not independently exposed. Managed allocations and
inspected proof/solver thread affinities stay within the host's eight-CPU
allocation, guest CPUs 0–7. These are focused development results. Final
original-bundle closure, complete validation, Rosetta promotion and independent
review remain outstanding; PR #424 stays draft.

### Scanner callee closure and shared source checkpoint, 15:16 UTC

The [scanner callee/termination packet](evidence/bounded-library-packages-416-20261122/imported-package/callee-termination/README.md)
records `20261127T151131-ab9ff5025a7b`: a fresh 35,602-declaration audit and the
complete interpreted scanner equation, including finite execution for rejected
inputs and arbitrary incoming scratch storage. Its callees use the existing
source-interpretation premises on their actual lexical/package domains. The
source length supplies sufficient fuel for both loops; this introduces no new
language restriction. The checked modules are integrated at `a75cb67163`.

The latest source-layout integrations include the original successful
Specification's export order and preserved unit/state metadata (`fb5853fb3f`),
the complete Completion's source-derived frame context (`f094f673cb`), and the
Object reader's original name-prefix/domain interpretation (`87cdcd568f`).
The [static Boolean execution packet](evidence/bounded-library-packages-416-20261122/static-domain-calls-model/static-boolean-execution/lean-focused-evidence.json.gz)
records the separately checked operands, chains and complete condition-loop result
in `da59fc60c3`; its mutually recursive source-domain closure remains in progress.

Run `20261127T151426-5b6f06cce28c` is checking the prepared authoritative support,
call/static-Boolean and import-scanner bindings at `1501ff7f8a`. These three
targets share one full OutputBodyCertificate rebuild. This is an active,
focused source checkpoint, not a passed full Lean audit. It uses two workers,
two threads per process and a 16,384 MiB per-process threshold, with observed
affinity on guest CPUs 4–5 under the host's eight-CPU allocation. The primary
proof/source/script inventory is frozen during the run. Private proof work and
same-source native helper checks continue within their managed allocations;
new proof commits wait for a safe integration boundary. Complete feature
validation, Rosetta promotion and independent review remain outstanding.


### Independent review response and namespace repairs, 18:36 UTC

The [retained independent review](reviews/review-3c0dde8f0d/README.md) found two
new admission blockers at published head `3c0dde8f0d`: package-name hiding of
use-visible runtime operations (#426), and library names conflicting with
Standard (#427). The owner authorized their repair first, within #416.
The earlier `151426-5b6f06cce28c` shared-source run was interrupted; its two
completed certificate chunks do not constitute a successful target/audit run.
Its freeze is over, and the previously queued declaration/Object/static-Boolean
proofs have been integrated through `b29bf28ea9`.

The native repair now checks the imported package name in shared
`Operation_After`, including argument initialization. The identity policy derives
28 excluded Standard identifiers from Ada A.1 and the pinned frontend, while
preserving legal operation-name packages, qualified calls and Standard/Nul.
The [84-case analyzer/frontend matrix](evidence/bounded-library-packages-416-20261127/namespace-regressions/README.md)
passed. The integrated [CLI/catalogue checks](evidence/bounded-library-packages-416-20261127/namespace-cli/README.md)
then passed all four selected tests. The whole Names unit passed 138 native
checks (`20261127T183145-df8197ddc96d`); Package_Name_Allowed passed 113 checks
(`20261127T183236-cbad4c88cef4`). Full affected callers and complete validation
remain separate requirements.

Focused formal-mode proof `20261127T182715-47e3d0ea2521` derives the original
specification's input-only function modes and physical formal-table bounds
through all completions and final Main metadata; see the
[formal-mode packet](evidence/bounded-library-packages-416-20261122/package-original-formal-modes/README.md).
All three continuing proof subthreads were selected as GPT-6 Astra Max; live
runtime settings and token/cost totals are not independently exposed. Each uses
a two-worker/two-thread share within the eight-CPU host allocation. The original
statement/initializer decoder and complete source-bound automatic-completion
endpoint remain unfinished. PR #424 stays draft, and no support is promoted.


### Main interpretation and focused coverage reconciliation, 19:17 UTC

The [Main proof packet](evidence/bounded-library-packages-416-20261122/main-static-witness/README.md)
retains the failed normalization attempts, successful intermediate checks and
final `20261127T191054-df5ffb22aaf2` result (22,162 declarations). Three equations
for argument handling, declarations and completion replace whole-command
expansion. They quantify arbitrary locals, continuations and callees; all twelve
Static assertions and the named Input local remain in the typed source. Neither
the input domain nor the theorem budget was weakened. The final authoritative
Main and Analyze source bindings are prepared but have not yet passed the shared
OutputBody checkpoint.

The [native continuation packet](evidence/bounded-library-packages-416-20261127/native-continuation/README.md)
records Signature's 79-check pass (`20261127T184159-a0acf00fba2f`) and
Specification's 45-check pass (`20261127T185933-2055189d72e9`), including preservation
of unit spans on failure returns. It also reconciles changed inherited contracts
and callers against retained evidence. The new-helper queue alone does not cover
those inherited changes. A canonical focused Output_Profile unit run will cover
the reconciled set after the pending Main and Analyze gates, before the complete
compiler audit; standalone helper coverage must still be checked.

Original function assignments and procedure actual/output flow now have focused
source-to-checker links. The [global reset packet](evidence/bounded-library-packages-416-20261122/package-procedure-global-reset/README.md)
records `20261127T191316-0a0ffe407833` (30,959 declarations): the exact native reset
fold and its representation bridge. Its source-derived visibility/layout premises
are the next proof step, not established facts of this checkpoint. Signature's
imported callee-domain proof is also in focused development.

The continuing subthreads remain selected GPT-6 Astra Max; live model/effort and
whole-session cost are not independently exposed. Checks use managed two-worker
shares under the host's eight-CPU allocation. Linux reports eight CPUs; the latest
inspection found every active managed worker thread within guest CPUs 0–7.
Complete source and semantic closure, native/Lean audits, final applicable tests,
Rosetta delivery and independent review remain outstanding. No support promotion
or merge readiness is claimed.

### Metadata projections and complete Signature loop, 19:50 UTC

The complete native Main attempt `20261127T190610-5f1996739339` retained two
unproved projections from `Valid_Metadata`; its other context, flow and caller
assertions passed. The repair exports the package-name validity and Main start
bound already established by that predicate's unchanged body, without narrowing
its input domain. The whole Package_Bindings unit then passed all 151 checks
(28 flow, 123 proof) in `20261127T193818-29ae74a7539e`. The
[source packet](evidence/bounded-library-packages-416-20261127/metadata-projection-source/README.md)
records the matching specification/header witness and semantic projection check,
including a fresh 22,065-declaration audit and the comparison of all 1,552
captured inputs. Main retry `20261127T193939-4dba03f7ee42` remains active; Analyze
and the focused Output_Profile unit gate follow it.

The [Signature loop packet](evidence/bounded-library-packages-416-20261127/signature-loop-imports/README.md)
closes the imported lexical, name, visibility, type and validity calls through
the complete formal loop and exact terminating result. It includes malformed
metadata, completion mismatch, capacity failure and partial-storage rejection.
The successful domain and whole-loop checks audited 46,743 and 46,755 declarations;
the preceding proof-draft failure remains failed. Native Append_Package_Formal
projection and authoritative source binding remain their distinct obligations.
Specification branch imports and final source composition are still in progress.

The [visible-state packet](evidence/bounded-library-packages-416-20261122/visible-state-layout/README.md)
and [original procedure target packet](evidence/bounded-library-packages-416-20261122/package-procedure-target-cells/README.md)
connect original defining spans, state identity and exact write/reset membership.
The no-later-shadow invariant now follows through the state, formal and local
declaration histories; its final routine-body context assembly remains pending.
These focused results do not yet establish the complete application endpoint.

The three continuing proof/native subthreads remain selected GPT-6 Astra Max.
Live lead model/effort and whole-session cost are not independently exposed.
Managed checks retain two-worker shares, two threads per Lean process and the
host's eight-CPU allocation. Every inspected proof/solver thread was confined to
guest CPUs 0–7, with no affinity exception. Complete native and Lean assurance,
final regression applicability, Rosetta promotion and independent closing review
remain required before this feature is supported.

### Main and Analyze gates, Specification boundaries and conditional composition, 20:17 UTC

The [native continuation packet](evidence/bounded-library-packages-416-20261127/native-continuation/README.md)
now records successful complete-helper checks for Main (52/52,
`20261127T193939-4dba03f7ee42`) and Analyze_Application (30/30,
`20261127T195352-f016f03f782d`). The canonical focused Output_Profile unit run
`20261127T195636-5b2a2f886237` is active on frozen native inputs. It covers the
reconciled changed inherited helper/caller set before a complete compiler audit;
no whole-unit result is claimed yet.

The [Specification boundary packet](evidence/bounded-library-packages-416-20261127/specification-boundary-imports/README.md)
records the full typed Signature reader and imported lexical/name interpretation
of the Specification entry and footer. Focused run `20261127T200639-c8a6099a16c9`
passed a fresh 48,264-declaration audit; all 1,541 captured source hashes match.
Specification branch/loop imported-call composition remains open. Its private
dependency refresh identified a stale Package_Bindings specification copy; the
exact already-approved metadata postcondition must be synchronized before the
next check. This is a workspace dependency mismatch, not a new native repair.

The [conditional composition packet](evidence/bounded-library-packages-416-20261122/package-conditional-source-checking/README.md)
records `20261127T200925-8f0e179f3cbe` (29,633 audited declarations). It relates
every original IF/ELSIF/ELSE arm and native accumulated flow to the nested semantic
checker; unreachable arms remain included. The recursive caller must still
derive each condition meaning and child result. Main's source-origin invariant
and private-state reset consumer are in focused development, including the
required original-source unit-table equality at the application join.

Authoritative source batch `20261127T195949-9affe71500da` runs in the isolated
`packages-416-support-proof` worktree. Its inputs remain stable while semantic
integration proceeds elsewhere. The running proof/native subthreads retain their
selected GPT-6 Astra Max settings; live model/effort confirmation is unavailable.
Managed jobs share eight workers in two-worker allocations; the 20:12 UTC
process/thread inspection found only CPU pairs 0–1, 2–3, 4–5 and 6–7, with no
thread outside the host's eight-CPU allocation. The Main origin check is another
focused development run. Complete original-bundle assurance, final native/Lean
audits, regression applicability, Rosetta promotion and independent closing
review remain required. PR #424 stays draft; no support or merge claim changes.

### Original loop composition and Main boundary imports, 20:47 UTC

The [Main origin packet](evidence/bounded-library-packages-416-20261127/main-private-state-origins/README.md)
records run `20261127T202642-b50241972628` (34,630 declarations): unqualified
Main scalars originate after private package state, through imports, argument
initialization, ordinary declarations and local callable declarations. These
original positions establish that Main calls cannot reset a hidden private state
slot. The metadata/original unit-table equality needed by the final application
join is derived from Analyze's accepted route, not added to standalone Main's
precondition.

The [original header packet](evidence/bounded-library-packages-416-20261122/package-original-condition-and-counted-header/README.md),
[array-header packet](evidence/bounded-library-packages-416-20261122/package-original-array-loop-header/README.md)
and [loop-composition packet](evidence/bounded-library-packages-416-20261122/package-original-loop-checker-composition/README.md)
record successful focused checks of original conditions and counted/Range headers,
constant-array iteration headers, and the counted/array semantic checker steps.
Runs `20261127T202753-bfb19611fb04`, `20261127T203307-d25fda8736bf` and
`20261127T204040-5f04c4eedcb7` audited 32,382, 30,944 and 32,357 declarations,
respectively. Recursive child decoding remains a separate obligation; these
composition lemmas expose their child hypotheses rather than assuming the final
application is checked.

The [Main boundary packet](evidence/bounded-library-packages-416-20261127/main-boundary-imports/README.md)
records run `20261127T203822-1db710cc486e` (47,754 declarations, all 1,569 captured
inputs matching). Main context/header/footer calls and imported-frame execution
now consume their source-interpreted helpers on derived native domains. The
[Specification domain packet](evidence/bounded-library-packages-416-20261122/specification-imports/README.md)
records the successful initial-frame, name, continuation and subtype domains
(70,618 declarations); Signature/Object branch-domain repairs and whole
Specification call composition continue in focused checks.

The canonical Output_Profile unit run `20261127T195636-5b2a2f886237` and isolated
authoritative-source batch `20261127T195949-9affe71500da` remain active with frozen
inputs. No whole-unit or source-batch result is claimed yet. Original recursive
statement decoding, declaration/initializer obligation inventory, package/Main
aggregation and the final original-source/tool endpoint still require completion.
Main's spelling-helper interpretation is being added over arbitrary Ada String
bounds; it is not silently replaced by a one-based-only equation.

The continuing subthreads retain their selected GPT-6 Astra Max settings; live
runtime settings are not independently exposed. All managed jobs retain shared
two-worker allocations within the eight-CPU host limit. The latest inspection
found no managed process or thread outside guest CPUs 0–7. Complete native and
Lean/source audits, final regression applicability, Rosetta promotion and
independent closing review remain outstanding. PR #424 stays draft and no merge
is authorized.


### Specification closure and Main declarations, 21:10 UTC

The [Specification imported-call packet](evidence/bounded-library-packages-416-20261122/specification-imports/README.md)
now includes the complete branch and typed-loop composition (`e452675352`).
The final focused run `20261127T205603-fabb5f3b8fc0` passed a fresh audit of
72,081 declarations with all 1,533 captured inputs matching. It preserves
arbitrary initial metadata and storage, rejected paths and partial writes.
Its shared static Boolean reader remains explicit until the imported-leaf
interpretation is joined.

The original recursive source-tree representation (`dfd3d9ec6d`) passed
`20261127T205831-0e37decb6ce6`, auditing 23,860 declarations. It retains every
conditional arm, loop and tail; it does not embed a semantic checker certificate.
Extraction and native child-domain preservation remain in progress. The
[Main declaration packet](evidence/bounded-library-packages-416-20261127/main-declaration-imports/README.md)
records `20261127T210746-03a0729003ec`: 48,627 declarations and all 1,573 captured
inputs matching. The argument/declaration readers now have exact inherited
meanings and returned native domains, including rejected states. The earlier
record-layout draft failure is retained separately.

The [residual closure inventory](evidence/bounded-library-packages-416-20261122/specification-imports/residual-closure-inventory.md)
distinguishes checked models from still-open original-callee composition. Work
continues on static Boolean imported leaves, Charge_Unit's two-output semantics,
Routine_Frame/Completion imports, package-unit evaluator existence and remaining
Main/recursive-body joins. These are required delivery work, not deferred
hardening. The final source/tool endpoint must derive the applicable child
preconditions and cannot assume an accepted decoder or safety certificate.

Native whole-unit run `20261127T195636-5b2a2f886237` and authoritative source batch
`20261127T195949-9affe71500da` remain active on frozen inputs. The source batch has
built all eight OutputBodyLines chunks and OutputBodyCertificate; its full
requested target/audit result is still pending. No complete feature assurance
is claimed. All 54 inspected proof/tool threads were confined to guest CPUs
0–7, with no exception. Proof subthreads remain selected Astra Max; live runtime
settings are not independently exposed. Complete native/Lean checks, final
regression/Rosetta delivery and independent closing review remain outstanding.
PR #424 stays draft; no merge or successor implementation is authorized.


### Static readers, Unit/Main imports and source reconciliation, 21:43 UTC

The [static Boolean imported-source packet](evidence/bounded-library-packages-416-20261127/static-boolean-imports/README.md)
closes all nine imported leaves plus the two actual scalar-empty operands. Run
`20261127T212948-73c26a2026c3` passed 72,030 audited declarations and all 1,588
captured input hashes. The recursive reader's equality to its model is derived
from original body equations and native contracts; it is not an assumed result.
The [Charge packet](evidence/bounded-library-packages-416-20261122/charge-unit/README.md)
records full-domain two-output and termination proofs, while the
[independent Charge review](evidence/bounded-library-packages-416-20261127/charge-unit-review/README.md)
found no consequential defect within that scope. Authoritative extraction is
still counted separately from its focused contract proof.

The [Unit/Main import packet](evidence/bounded-library-packages-416-20261127/unit-main-flow-imports/README.md)
passed run `20261127T213637-16fea80095af`, auditing 74,533 declarations with all
1,576 inputs matching. It derives the Unit prefix and lexical/Object steps,
Main's Context_Of/Body_Of and their full native domains, and Completed's path
meaning. The [Object frame packet](evidence/bounded-library-packages-416-20261122/object-reader-frame/README.md)
passed 70,648 declarations and 1,545 input hashes; successful Object reads preserve
ReaderFrame in both modes without an added executable guard. The separate Unit
totality packet already supplies finite original typed evaluation on its model
readers. Routine_Frame/Completion, complete Unit/Main joins, recursive semantic
checking and the full initializer-obligation inventory remain required work.

Source batch `20261127T195949-9affe71500da` finished failed: all nine requested
package source-check modules built, but NamesSourceBridge depended on a stale
ReviewedOutputShape literal from #410. OutputBodyCertificate itself passed.
The independently expected literal grows from 81,277 to 101,032 tokens. The
follow-up built both Charge and package-spelling authoritative checks, then
encountered declaration-depth limits on the expanded literal. Ordered named
chunks preserve every token without raising the existing proof budgets; the
combined source checkpoint is being rechecked. These failed runs remain failed,
and no successful aggregate source audit is claimed yet.

The original native run `20261127T195636-5b2a2f886237` remains productive.
Interim Why3 sessions show three Array_Declaration_Model timeouts without a
counterexample; final policy/report classification must precede a repair or
retry. Its captured native inputs remain frozen. Concurrent proof shares remain
within eight managed workers and guest CPUs 0–7. The Object packet records its
actual 0–1 affinity rather than the originally discussed 4–5 share. Subsequent
shares use explicit coordinated taskset masks. Proof subthreads are selected
Astra Max; runtime settings are not independently exposed. No merge, successor
implementation or completed feature support is authorized or claimed.


### Authoritative source checkpoint and remaining composition, 22:08 UTC

The [authoritative-source packet](evidence/bounded-library-packages-416-20261127/authoritative-source/README.md)
now passes run `20261127T215103-4a33f22a63ac`: 137,382 audited declarations,
463 imported project modules and 1,605 matching captured inputs. All twelve
requested package/admission/name source targets passed. Independent re-lexing
identified two stale inherited Output_Profile literals; the specification is
1,048 tokens and the body 101,032. Thirteen ordered body chunks retain the
original local budgets and the kernel-checked equality. The other eight stored
source shapes matched. Failed attempts remain failed; the successful run reused
completed certificates. This is focused source assurance, not the complete
semantic endpoint or final project audit. The source worktree's cache is retained
for later documented reuse; no transfer has yet occurred.

The [Main declaration composition](evidence/bounded-library-packages-416-20261127/main-declaration-composition/README.md)
and [body-domain packet](evidence/bounded-library-packages-416-20261127/main-body-domains/README.md)
derive the recursive reader's actual preconditions from Main's imports and
declarations, without assuming later acceptance. The latter passed 75,101
declarations. [Routine_Frame](evidence/bounded-library-packages-416-20261122/routine-frame/README.md),
[completing Signature metadata](evidence/bounded-library-packages-416-20261122/completion-metadata-types/README.md)
and [Object initializer cursors](evidence/bounded-library-packages-416-20261122/object-initializer-bounds/README.md)
now have focused complete-domain results. The recursive outcome packet was
rechecked against current inputs: 34,780 declarations and 1,613 matching hashes.
The earlier evidence is retained as historical, with its synchronization recorded.

Main body/footer composition, Completion/Unit composition, original recursive
primitive imports, semantic extraction, initializer inventories and the final
original-source/tool endpoint remain in progress. Main's declaration inventory
must retain its imported package constants; standalone empty-initial-frame facts
are not assumed to cover that case. Native unit run
`20261127T195636-5b2a2f886237` is still active, with three interim
Array_Declaration_Model timeouts awaiting final classification. No complete
checkpoint is started while required focused helper coverage remains unresolved.

The existing three proof subthreads continue at selected Astra Max, with runtime
settings not independently exposed. Coordinated two-worker/two-thread shares
remain within the host's eight-CPU allocation; all 27 proof/tool threads in the
latest inspection were within guest CPUs 0–7. PR #424 remains draft, #426/#427
remain open, and final native/Lean assurance, regressions, Rosetta delivery and
independent closing review are outstanding. No feature merge is authorized.


### Main composition, initializer histories and inherited callers, 22:26 UTC

The [Main body/footer packet](evidence/bounded-library-packages-416-20261127/main-body-composition/README.md)
passed 75,566 declarations, and [accepted source history](evidence/bounded-library-packages-416-20261127/main-source-reading/README.md)
passed 75,569. Original Main imports, declarations, recursive input, footer and
EOF now compose over the complete native precondition and every rejection path.
Acceptance constructs the original recursive TailTree without assuming a semantic
checker result. The original recursive equations remain explicit until their
primitive imports are completely joined.

The [callee-import packet](evidence/bounded-library-packages-416-20261127/callee-imports/README.md)
passed 46,618 declarations, binding original reference/scalar/Boolean/name/routine
lookups with the actual completion-prefix guard. The [inherited body packet](evidence/bounded-library-packages-416-20261127/inherited-body-imports/README.md)
passed 76,549 declarations, deriving basic/target/token/condition/join meanings
from existing raw helper definitions, retaining the exact native context. It
built previously uncached inherited dependencies; no cache transfer occurred.

The [initializer aggregation packet](evidence/bounded-library-packages-416-20261122/package-initializer-aggregation/README.md)
now contains successful per-object syntax/discharge and state/local source-history
folds. Its output history proves that every leading output RHS uses the original
pre-output frame. This is partial aggregation: imported constants need explicit
semantic bindings derived from original elaboration, and the generic Main String
region argument must retain original bounds without assuming an empty entry frame.

Current-primary inherited caller failures surfaced through newly exercised
dependencies: ProcedureDeclarationSyntax still constructs the old scalar record;
FunctionFrameValidity lacks qualifier validity; FunctionDeclarationInitialDomain
lacks the added context requirement; ComposeInitializerTrace omits contextFirst
on a raw String expression. Related FunctionDeclarationNative and procedure
renderer clauses also retain old scalar/Boolean aggregate shapes despite the
eight/seven-field native source. These are required #416 integration repairs,
assigned with focused source checks against the unchanged authoritative source.
They are not waived by removing an unnecessary import and must be resolved before
the complete Lean checkpoint. No native source or accepted-language change is
made to address these proof representation errors.

Native unit run `20261127T195636-5b2a2f886237` continues on frozen inputs, now in
Declaration_At. Boolean and Character declaration sessions have proved interim
roots; the same three Array_Declaration_Model/At goals still show timeouts.
Final audit classification remains pending. Shared reservations and affinity
remain within CPUs0–7. The three ongoing proof roles retain selected Astra Max
settings, with runtime settings not independently exposed. Final source/semantic
composition, complete assurance, regression/Rosetta delivery and independent
closing review remain outstanding; PR #424 stays draft and no merge is authorized.


### Recursive Main and imported native payloads, 22:40 UTC

The [recursive Main packet](evidence/bounded-library-packages-416-20261122/package-main-recursive-meaning/README.md)
passed `20261127T222621-4da75140ec94`, auditing 37,632 declarations. Original-cursor
induction closes Statement/Tail child callbacks across every admitted conditional
and loop, deriving the combined-table checker and obligations. Binding actual
source-reader dictionaries and deriving MainScope from original histories remain
required; this is not yet the final original-source endpoint.

The [Completion native-leaf packet](evidence/bounded-library-packages-416-20261122/completion-native-leaves/README.md)
passed 81,608 declarations, and the [body-domain packet](evidence/bounded-library-packages-416-20261122/completion-body-domains/README.md)
passed 82,106. Actual_After/Function_Return_After now have source-derived native
interpretations and projected-context witness independence. Output-frame and
body/return preconditions follow from original stages. Full Completion transport
and recursive effect-mask widths remain in progress.

The [inherited formal repairs](evidence/bounded-library-packages-416-20261122/inherited-formal-callers/README.md)
passed both exact aggregate-renderer source targets with 18,702 declarations.
Four inherited callers/renderers now retain the added context/qualifier fields;
no Ada or pin-only change was made. The recorded cache transfer reused 240
artifacts for 15 matching modules from the idle authoritative-source worktree,
including sidecars and traces, revalidated by Lake. Newly exercised callers in
ProcedureFrameMeaning and FunctionHeaderSource still need matching repairs.

The [payload-import packet](evidence/bounded-library-packages-416-20261127/call-payload-imports/README.md)
passed 73,325 declarations, composing original input and writable-actual readers
with state-target lookup on their full native domains. Two failed local drafts
remain failed; no accepted-call assumption was added. The enclosing argument
loop, alias/reset passes and complete call composition remain open. The
[initializer packet](evidence/bounded-library-packages-416-20261122/package-initializer-aggregation/README.md)
now derives exact exported scalar values from the original nonlocal singleton
guard and raw expression, and restores contextFirst in String source traces.
Its latest focused batch passed 72,860 declarations.

The package-body checker needs a flow invariant when a loop binder hides a
private state name. Native reset skips the hidden row, while the semantic global
mapping must still denote the actual package state. The focused argument proves
that omitted rows already hold their declared ranges, making the semantic reset
unchanged. Recursive preservation remains open. This proof gap is not evidence
of an admitted-source behavior defect or permission to restrict the language.

Native unit run `20261127T195636-5b2a2f886237` continues on frozen inputs.
Read_Declarations has a proved interim root; three timed-out Array_Declaration_Model/At
goals still await final audit classification. No complete native run starts while
focused requirements remain unresolved. The latest inspection found no proof/tool
thread outside CPUs 0–7. Proof roles remain selected Astra Max; runtime settings
are not independently exposed. Final source/semantic composition, complete
assurance, regression/Rosetta delivery and independent closing review remain
outstanding. PR #424 stays draft and no merge is authorized.

### Complete call imports and recursive package checking, 23:17 UTC

The [complete call-import checkpoint](evidence/bounded-library-packages-416-20261127/call-composition/README.md)
passed 77,344 audited declarations. It composes the original callee selection,
argument scan, aliases, state reset and final validity guard, including rejected
calls and arbitrary scratch locals. Its recorded success was retained after the
lead resumed, without another run. The
[inherited projection checkpoint](evidence/bounded-library-packages-416-20261127/inherited-projection/README.md)
passed 76,968 declarations, preserving the original native contexts and the
assignment-result helper's component-only domain.

The [Completion contract checkpoint](evidence/bounded-library-packages-416-20261127/completion-native-contract/README.md)
passed 82,639 declarations. Complete Completion transport, metadata preservation
and typed native execution now compose. This does not supply the enclosing
original-program safety endpoint. The
[initializer checkpoint](evidence/bounded-library-packages-416-20261122/package-initializer-aggregation/README.md)
passed 78,162 declarations, adding imported Main/String bounds and original
Boolean initializer consumers. Source-derived seed/range evolution and the
output/body initialization phases still need to join it.

The [recursive package checkpoint](evidence/bounded-library-packages-416-20261122/package-recursive-meaning/README.md)
passed 37,909 declarations. Original-cursor induction derives source syntax and
the complete package-body checker through all arms, sequential tails and counted
loops, preserving hidden private-state ranges. Its local scope and entry-range
hypotheses must still be derived from declaration histories, and its recursive
equations must receive the actual primitive imports. They are not additional
assumptions in a completed source endpoint. The phased routine/library consumer
and original Main/Unit/external-tool endpoint remain required.

Proof subthreads retain their selected Astra Max roles; runtime settings and
whole-team token/cost measurements are not independently exposed. Linux detects
eight CPUs. Active proof/solver threads were checked within guest CPUs 0–7,
with no affinity exceptions; temporary two-worker shares are coordinated between
the existing streams. Native unit run `20261127T195636-5b2a2f886237` remains on
frozen inputs, with the earlier array-declaration timeouts awaiting final audit.
Complete native/Lean validation, regression applicability, Rosetta delivery and
independent closing review remain outstanding. PR #424 stays draft; #426/#427
remain open. No merge or successor implementation is authorized.

### Entry scope, ordered initializer checks and Basic composition, 23:33 UTC

The [whole Basic import composition](evidence/bounded-library-packages-416-20261127/basic-composition/README.md)
passed 84,382 audited declarations. Every original Basic branch now uses its
source-defined inherited and package-call libraries, including failed-call
fallback and assignment-result handling. State-effect callbacks remain explicit
for the separate effect join. The
[native recursive-domain repair](evidence/bounded-library-packages-416-20261127/recursive-native-types/README.md)
retains the metadata component subtypes already required by the native records;
it adds no successful-parser or semantic-check premise.

The [routine entry-scope checkpoint](evidence/bounded-library-packages-416-20261122/package-routine-entry-scope/README.md)
passed 38,983 declarations. Original Completion histories derive the closed
reader frame, visible state fields, body entry ranges and hidden-state invariant.
The recursive scope uses exactly the nonempty state bounds derived from final
metadata, rather than an unused whole-metadata assumption. The
[initializer packet](evidence/bounded-library-packages-416-20261122/package-initializer-aggregation/README.md)
now also retains the source-ordered local initializer fold and exact full-map
local-to-output widening, including hidden cells. Immutable constant seeds and
the output-to-body phase still need to join these results. The phased
[application consumer](evidence/bounded-library-packages-416-20261122/package-phased-application/README.md)
is checked, but its original-source aggregation is not complete.

Canonical native unit run `20261127T195636-5b2a2f886237` advanced to
Read_Condition_Into at 23:30 UTC. Six attempted-unproved array-declaration roots
remain visible, three each in Array_Declaration_Model and Array_Declaration_At;
all observed direct attempts timed out. Its final audit remains pending.
No complete native run starts with unresolved focused obligations. Complete
Unit/recursive source composition, source-derived initializer/effect aggregation,
full assurance, applicable regressions, Rosetta delivery and final independent
review remain outstanding. The selected proof roles remain Astra Max, with live
runtime settings not independently exposed. PR #424 remains draft, and no merge
or successor implementation is authorized.

### Complete Unit imports and initializer phase join, 23:50 UTC

The [Unit import checkpoint](evidence/bounded-library-packages-416-20261127/unit-native-composition/README.md)
passed 85,146 declarations, followed by a checked public type-identity export
(85,147). It derives state-table component types, preserves reader/metadata domains
through every continuing step, proves termination of the original typed Unit body,
and identifies its metadata/Accepted result with the total source reader. Rejected
input and partial metadata writes are included. Failed normalization drafts are
retained; no domain or proof budget was changed to obtain success.

The [Statement/Tail primitive imports](evidence/bounded-library-packages-416-20261127/statement-imports/README.md)
and [recursive source-definition composition](evidence/bounded-library-packages-416-20261127/recursive-source-imports/README.md)
passed 81,379 and 84,648 declarations. They preserve the original recursive,
effect and validity symbols while deriving the normalized interface from typed
source-definition equations. The enclosing authoritative-source connection
remains required. The [source seed checkpoint](evidence/bounded-library-packages-416-20261122/package-source-seeds/README.md)
passed 80,029 declarations: original specification constants and full input
formal domains now have the checked invocation seed equations. Raw original
initializer syntax, arithmetic checks and value correspondence remain distinct
from constant loads.

The [initializer phase join](evidence/bounded-library-packages-416-20261122/package-initializer-aggregation/README.md)
passed 78,423 declarations. Original output histories preserve their preappend
scopes; installed formal rows match the complete declared body range map. The
source phase theorem composes seed, local and output checks with exactly the two
native widening phases. Original declaration-range obligations remain in their
separate inventory for inclusion in the enclosing endpoint.

Remaining proof work is now the Specification/outer reader metadata joins,
source seed-to-row correspondence, routine result/effect aggregation, and the
final original-application/source/tool endpoint. Semantic, source and effect
subthreads retain selected Astra Max roles; runtime settings are not independently
exposed. The existing native unit run remains active with the six provisional
array-declaration timeouts awaiting its final audit. Complete assurance,
regressions, Rosetta delivery and independent final review remain required.
PR #424 remains draft; no merge or successor feature is authorized.

### Specification contracts and original entry rows, 2026-11-28 00:02 UTC

The [Specification result contract](evidence/bounded-library-packages-416-20261127/specification-metadata-imports/README.md)
passed 75,239 audited declarations. Its original typed execution preserves the
unit table and derives metadata component types and the returned parser frame,
including rejected inputs and partial writes. The preceding signature and
Specification component-type checks are retained separately. The actual Bundle
representation supplies the initial metadata types; no successful parse or
semantic safety certificate is added as a premise.

The [source entry-row checkpoint](evidence/bounded-library-packages-416-20261122/package-entry-seed-rows/README.md)
passed 75,368 declarations. Original specification constants, private state and
input formal rows determine the invocation's scalar range map through native
widening and hiding. The [result/effect checkpoint](evidence/bounded-library-packages-416-20261122/package-result-effect-aggregation/README.md)
passed 38,991 declarations, deriving original function return syntax, argument
checking and result obligations, together with expression/condition global reads.
Procedure output coverage and complete routine effects remain in progress.

The lead is joining these domains through Analyze_Application into Main in a
separate focused check. Declaration-derived Main scope, phased library aggregation
and the final original-source/tool endpoint remain required. These focused
successes do not constitute the complete feature assurance checkpoint.

Native unit run `20261127T195636-5b2a2f886237` remains active on unchanged native
inputs. Its six provisional array-declaration roots have only timeout attempts;
the final report and whole-helper coverage reconciliation are still pending.
The host detects eight CPUs, and all inspected managed proof/tool threads remain
within guest CPUs 0–7. Proof roles retain the selected Astra Max setting; live
runtime settings are not independently exposed. Complete validation, applicable
regressions, Rosetta delivery and independent closing review remain outstanding.
PR #424 stays draft; #426/#427 remain open. No merge or successor work is authorized.

### Original Main scope and application summary consumer, 2026-11-28 00:34 UTC

The [Main entry-scope proof](evidence/bounded-library-packages-416-20261128/main-entry-scope/README.md)
passed its focused check and fresh 83,100-declaration audit. Original imports,
optional argument and declaration histories now derive Main's source cursor and
scope. The [argument String adapter](evidence/bounded-library-packages-416-20261128/main-argument-string-bounds/README.md)
passed 83,115 declarations and derives actual bounds, initialization traces and
runtime fit for every bounded printable argument, including an empty one.

The [admission and summary consumer](evidence/bounded-library-packages-416-20261128/admission-summary-composition/README.md)
passed 86,501 declarations. Analyze's original Specification/Unit results and
executable guards establish Main's full callee domain. Routine checks retain
original initializer phases, body and results; inferred effects must be included
in the compiler's conservative summary. The application consumer uses that
checked library for execution safety and obligation discharge. Source construction
of the complete library and application remains required, with no successful
semantic decoder or safety certificate assumed from the program author.

The native containing-unit check remains active on its frozen source inputs.
Its six provisional array-declaration timeout roots await the final report and
diagnosis; no complete native checkpoint will start while they remain unresolved.
Eight CPUs are detected after reboot, and an inspection of active tool processes
and their threads found no affinity outside guest CPUs 0–7. Concurrent managed
allocations remain within that ceiling. Complete native/Lean assurance,
regressions, Rosetta promotion and independent closing review remain pending.
PR #424 stays draft, and #426/#427 remain open through final validation.

### Original source assembly and timeout policy, 2026-11-28 00:53 UTC

The [source/native composition bridge](evidence/bounded-library-packages-416-20261128/original-source-bridge/README.md)
passed a focused 86,252-declaration audit. It joins Analyze, Specification,
Completion/Unit, Main and their primitive guards through the same supplied
libraries, including rejected inputs and arbitrary caller locals. Its
authoritative-source companion is prepared but explicitly unbuilt until the
stable source checkpoint. The [original routine assembly](evidence/bounded-library-packages-416-20261128/source-routine-library/README.md)
passed 84,497 declarations: original frame/history facts derive every completion
entry and its phased checks, with a library fold ready to consume independently
derived effect inclusion. The [effect packet](evidence/bounded-library-packages-416-20261122/package-result-effect-aggregation/README.md)
now establishes effect-inference existence and native bitmask membership; complete
body/footer inclusion and global initializer value aggregation remain in progress.

The owner instructed **“Double all default timeouts if it will help.”** All 18
main-prover attempts on the six provisional array-declaration roots timed out
at 30 seconds. The [prepared policy branch](https://github.com/berkeleynerd/silver/tree/fix/packages-416-proof-timeout)
raises the shared native compiler solver default to 60 seconds per prover and
updates current guidance; 43 runner and 27 provenance tests pass. It also repairs
an independently reviewed existing source-policy omission for two exact package
metadata abstraction annotations, with all 79 auditor tests passing. Retained
failed records remain failed. Integrate commits `82a03c1413`, `84d9054704` and
`2b85e2654a` only after native run `20261127T195636-5b2a2f886237` terminates, so
its captured source/script inputs remain unchanged. Then inspect the final
mapped failures and check affected whole helpers under the new budget. No proof
success at 60 seconds is claimed. Lean has no managed wall-clock timeout; no
evidence supports doubling unrelated timeout settings.

Original application/source/tool composition, remaining focused native checks,
complete assurance, regressions, Rosetta promotion and independent closing
review remain required. The native job retains CPUs 2–3; semantic, source/value
and effect subthreads share 0–1, 4–5 and 6–7 respectively. The lead's temporary
Python-test use of 4–5 has ended. No merge or successor implementation is authorized.

### Original application assurance and coverage review, 2026-11-28 05:16 UTC

The [complete original-obligation join](evidence/bounded-library-packages-416-20261122/package-original-complete-obligations/README.md)
passed its focused Linux check and fresh 96,110-declaration audit at 02:53 UTC.
It derives source histories, complete routine effects, function state preservation,
Main runtime initialization and execution soundness from original native
acceptance. Independent review found missing raw declaration-obligation families
in earlier drafts; the retained corrections include Main String/Character and
argument bounds, Boolean checks, package routine-local Integer range expressions,
and Main/top-level callable-local Integer range expressions. The final scoped
reviews found no blocker. Earlier successful drafts retain their narrower scope.

The lead integrated the checked endpoint and its prerequisites. Comparison with
the focused run's 1,761 captured inputs found two older dependency files in that
private checkpoint: the integration branch already has the default name-context
proof and explicit procedure binding qualification fields. Those exact files
have been synchronized for the next source check; the private focused result is
not a claim of complete validation of the integrated tree.

The authoritative-source constructor and final source/tool join remain in
progress. A bounded follow-up checks applicability of the new raw range inventory
to the inherited standalone endpoint. Native containing-unit run
`20261127T195636-5b2a2f886237` remains productive after more than nine hours,
currently proving Application_Statement. Its inputs and CPUs 2–3 remain unchanged.
The native subthread is assessing an isolated canonical 60-second helper probe
without stopping that run. Complete native/Lean/project validation, applicable
regressions, Rosetta promotion and closing review remain required; PR #424 is draft.
