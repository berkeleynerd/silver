# Constant Integer-array iteration

Status: authorized implementation; not supported yet.

The [2026-10-28 owner instruction](session-memory.md#2026-10-28--constant-integer-array-iteration-authorized-as-a-stacked-pr)
authorizes [#264](https://github.com/berkeleynerd/silver/issues/264) under
[milestone 11](https://github.com/berkeleynerd/silver/milestone/11), as a stacked
successor to PR #263. The parent implementation is `0a85336c83`, merged as
`10cdcd274c`. Its preserved feature branch remains the successor PR base during
external review; successor implementation and publication do not modify that
review target or authorize merging the new feature during the review.

## Selected scope

Admit `for E of [reverse] A loop ... end loop;` for a visible existing constant,
anonymous fixed-size Integer-array object. Brackets denote optional syntax.
Visit each component once in increasing index order, or decreasing order with
`reverse`. Retain mandatory explicit initialization, nonempty static bounds and
the current source/operator/operand limits.

The driver is Rosetta [Loops/Foreach](../rosetta/l/loops/foreach/task.wiki): print
each collection element in order using the language's foreach construct. A
constant array `(-1, 0, 1, 2, 3)` and `Integer'Image (Value)` give a faithful
small example. The task requires neither input nor mutable-element writes.
The old indexed-loop assessment must be reconciled because Ada provides `of`.

The scoped element binding is immutable, nonstatic and refinable by the existing
scalar guards. Its entry interval is the full Integer range, consistent with
body array reads. Body-derived facts do not survive into another iteration or
escape the loop. Resolve the iterable once by binding identity and apply the
existing hiding rules; the new binder's name is unavailable in its own iterator
specification. Existing nested statements, guards, range loops, assignments to
other mutable objects, output and argument-shell Reject remain composable.

Widen mutable scalar facts before body analysis and preserve outer immutable
and index facts. The array is nonempty, so the independent String/input flow
uses the definitely-nonempty loop transfer. Declarations remain in the outer
declaration region. Mutable iterables, writes through the element binding,
subtype indications, filters, slices, general iterators and other component
types are outside this increment. Broad arrays #12 remains open.

## Assurance and discovery obligations

Ada RM 5.5.2 makes the iteration parameter constant for a constant iterable and
makes it denote the actual component; Ada does not snapshot the array. A scalar
value per iteration is a faithful model only after proving constant-component
preservation across every permitted body composition. Reuse the existing store
preservation, finite enumeration and flow lemmas; keep binder identities
separate from array storage through source-derived readiness. Do not assume a
native bound for arbitrary generic Lean identities. The compiler must prove and
compile the author's original `for ... of` bytes.

An early managed producer probe must cover forward/reverse order, guarded
element arithmetic/indexing, nesting, writes to a different array and name
hiding. Inspect the implicit iterator translation and exact report routes;
passing examples alone do not establish universal automatic discharge.

The shorter syntax changes the feature-local report envelope. The minimum
`for E of A loop` prefix is 15 bytes, so the previous `27*L + 8*W <= S` charge
for all loops cannot be inherited unchanged. Recheck the conservative combined
`24*L + 8*W <= S` charge, diagnostic multiplicity and implicit iterator checks
against the current 32 MiB Main allocation. The
[producer/capacity account](constant-array-iteration-report-capacity.md) records
the inspected expansion, production-setting probe and revised 31,269,376-byte
envelope, within that unchanged allocation. This is required feature-local
accounting within the unchanged source limit, not a reopening of #119.

Completion requires agreement of native/compiler/catalogue/specification,
universal composition and automatic-discharge proofs, exact actual-source
correspondence, complete native and Lean/module/axiom checkpoints, full reviewed
regression coverage, a narrow Rosetta mapping and independent review. Preserve
valid prior evidence and use existing managed runners. Do not broaden #246 or
introduce a general iterator framework or assurance mode.

| Round | Selected model/effort | Result and measurement limits |
| --- | --- | --- |
| Driver and scope selection | GPT-6.1 Sol / Extra High | The cached task requires ordered foreach output, not mutable iteration; a small constant Integer-array driver is faithful. Procedures/named subtypes would add independent call/alias/type machinery. Runtime settings and token/cost measurements unavailable. |
| Semantics and assurance design | GPT-6 Astra / Extra High | Confirmed constant-component semantics, preservation and hiding obligations, source-derived binder separation and the shorter-loop capacity premise. Existing reverse enumeration is reusable. Read-only; no proof/probe run or performance claim. Runtime settings and token/cost measurements unavailable. |

## Implementation checkpoint, 2026-10-28

The planning authorization reached main through PR #265 (`a2bb0a9f65`).
Implementation remains on `feat/constant-array-iteration`, with isolated native,
core-proof and source-correspondence worktrees. The stacked PR is not complete
or supported yet; full native/Lean/source/regression validation and independent
integration review remain outstanding.

The native change is a direct `of` branch in `Loop_Body`, sharing the existing
body flow logic with counted loops. The mathematical core has a dedicated
`arrayLoop` constructor. It captures the descriptor and index sequence once,
reads the actual component on each iteration and restores the scoped binder.
Its checker requires Full-range readonly array cells and binder separation,
including every nested body's lexical binders. The source proof derives that
separation from the existing allocation rules rather than assuming a native
bound on arbitrary mathematical identities.

| Round | Selected model/effort | Result and measurement limits |
| --- | --- | --- |
| Planning review | GPT-6.1 Sol / High | No actionable scope, authorization or premature-support finding. Reviewed the three planning files before PR #265. Runtime setting and token/cost measurements unavailable. |
| Native implementation and producer discovery | GPT-6.1 Sol / Extra High | Original-source branch and focused admission regressions; production no-unrolling probe passed with existing check/advisory classes. Self-hiding was rejected by the pinned Ada frontend. Two initial regression expectations were corrected: Reject returns, and an Integer-named element is legal while hiding the Image type mark. Complete validation remains pending. |
| Universal core extension | GPT-6 Astra / Extra High | Focused Statements, Execution, Obligations and SourceSyntax build/audit passed at `c679325e27`, 1 worker/thread, 8,192 MiB threshold; build 60.296 s, audit 9.245 s, 10,096 declarations. This is partial evidence; recursive component-preservation refinements and source integration continue. |
| Source correspondence | GPT-6 Astra / Extra High | Array/count header model and cursor/count/flow invariants passed focused checks at `23f6b82f82`. Parsed readings, meaning and typed native interpretation remain in progress. Runtime setting and token/cost measurements unavailable. |

The [report-capacity record](constant-array-iteration-report-capacity.md) retains
the precise source inputs and probe evidence. Native build
`20261028T102103-f46e6228b43e` and focused admission run
`20261028T102312-96fa6ff1dcfb` passed. These do not replace the final checkpoint.

The subsequent core checkpoint `73a40b56e5` passed fresh audit of 10,227
declarations in run `20261028T102938-f47d9f9056b0`. It includes recursive
component stability, ordered/unique enumeration and extreme-endpoint witnesses.
The source-model checkpoint `b7649bafed` passed its seven targets and fresh
16,468-declaration audit in `20261028T103509-43b36c151ccb` (249.614 s total).
The [independent core/source review](reviews/review-constant-array-iteration-core-20261028.md)
found no actionable defect in either layer; typed native interpretation and final
actual-source validation remain outside that verdict.

Native `Loop_Body` focused proof passed all 89 checks in
`20261028T102351-2fc5f52c3651`. The complete ten-method new regression file passed
in `20261028T103521-e9ff9a0ca62d`, including original-source native compile,
prove and execution in the argument shell. The native source was frozen at
SHA-256 `09858656aa96cdff7cc6f1ebc6683ce70885840e94df9706420b4c4e45ed6abc`
before the isolated output-certificate and complete native checkpoint began.

Independent integration review R1 found that existing catalogue expression and
guard entries omitted scoped elements even though the new iteration entry and
implementation admitted them. [#267](https://github.com/berkeleynerd/silver/issues/267)
records the correction to both catalogue copies and related language summaries.
The reviewer confirmed the repaired meanings; build
`20261028T110633-769e6cd4dab7` and catalogue byte-parity regression
`20261028T110712-42bfb28a9731` passed. The recognizer and output certificate are
unchanged. The active native checkpoint retains its original catalogue inputs;
a complete cached refresh will validate the corrected catalogue before delivery.

The final typed bridge at `3255e9ddecae` proves the unchanged
`LoopNative.eval_equation` by separating header selection from the shared body
and exit transfer. Native, Imports, Helpers, Sizing and exact loop rendering
passed together in `20261028T112717-49ee7b84b5ec`: 169.896 s build,
26.155 s fresh audit, 34,099 declarations and only the three approved
foundations. This focused run does not establish complete source correspondence.
The [integration review](reviews/review-constant-array-iteration-integration-20261028.md)
independently confirmed the final proof, source rendering and exact evidence
inputs without an actionable remaining defect in that bounded layer.

This round used GPT-6 Astra / Extra High for the equation repair and independent
review, and GPT-6.1 Sol / Extra High for bridge integration. The first broad
normalization attempt was deliberately interrupted; smaller private staging
lemmas closed the same statement. No native behavior, theorem assumption,
source representation or kernel-check policy was changed. Selected settings
are recorded; runtime confirmation and token/cost measurements are unavailable.
Complete native, source-certificate, whole-project and regression checkpoints
remain pending.

The complete 540-test run `20261028T110929-97e25e5a798e` retained 539
successes and one symlinked-TMPDIR fixture timeout at 180 seconds. All 788
captured inputs still matched before final proof integration. The only subsequent
governed changes were the four reviewed typed Lean files. Source-policy run
`20261028T123939-44279f5d51d8` passed 12 tests; platform run
`20261028T131129-d738104f578d` passed 16, including the timeout case with its
original timeout and assertions. Independent review accounts for all 540 IDs:
512 applicable retained passes and 28 successful reruns. The original complete
run remains failed. All 50 manifest samples and 106 executions passed.

The first complete native attempt was deliberately interrupted after discovering
that the private worktree lacked the retained parent solver cache. Of its first
26,847 generated cache keys, 25,857 already existed in the parent. Its completed
work and 27 partial report files were preserved. With native processes stopped,
59,719 missing parent entries were copied without overwriting current entries;
the Alire lock matched, and GNATprove retains responsibility for cache matching.
The [cache record](evidence/constant-array-iteration-20261028/native-cache-reuse.json)
keeps this setup correction distinct from assurance success. The final native
checkpoint uses the reviewed catalogue correction at `d155e60ccc`; its tracked
source, scripts and project inputs match the integration branch.
