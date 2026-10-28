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
against the current 32 MiB Main allocation. This is required feature-local
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
