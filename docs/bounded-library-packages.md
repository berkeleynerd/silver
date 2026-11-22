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

Runtime-confirmed agent settings and whole-team token/cost measurements are not
independently exposed. These exploratory results are not final compiler assurance.
