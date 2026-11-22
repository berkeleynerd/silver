# Bounded library packages and application units

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

All of these are development checkpoints. The remaining native helper/caller
contracts, whole-reader source correspondence, complete validation, final Rosetta
promotion and independent delivery review still block a support/completion claim.
