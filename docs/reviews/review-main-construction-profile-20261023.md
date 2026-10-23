# Main construction interface and restricted conversion review

2026-10-23 UTC, #178 under #119. **Accepted scoped tranche** at author freeze
`767007bf43ad1a7ef82b8d629ab460b6186f694e`: the normalized construction
interface, ordinary restricted array-conversion row, 43 primitive signatures
and their call-contract profiles. **#178 remains unfinished.** This supplies
neither the complete arbitrary-Main emitter nor numeric U/H bounds.

The [independent audit](../evidence/retained-main-construction-review-20261023/README.md)
passed its sole attempt: **13,792 checks in 0.599727 seconds**, with
0.735352 seconds wrapper time on Linux x86_64. Selected reviewer: GPT-6 Astra /
Extra High. Runtime model/effort confirmation, token usage and cost are
unavailable. The [round record](../evidence/retained-main-construction-review-20261023/round.json)
distinguishes the observation interval from execution time. No agent was spawned.

## Accepted construction row

The row assumes the ordinary rank-one String representation, resolved source
and target Ada identities, complete Integer-representation bound trees, and
the supplied source decisions for sliding, checks and static equal lengths.
Qualification, relaxed initialization, component conversion, predicates and
fixed-lower-bound sliding require their own rows. The accepted ordinary shape
premises exclude those branches here. The helper does not itself derive the
premises or validate arbitrary manually supplied Native/Program records.

**Target applicability is narrower than representation alone:** a nonstatic
target type entity reaching this row must be unconstrained Standard.String.
`Insert_Array_Conversion:1458`
selects the length check using `Is_Constrained`, whereas the frozen interface
selects it using `target.static`. A constrained target with dynamic bounds is
not covered by that Boolean partition, despite sharing the nonstatic String
representation. The already pinned
[Main shape induction](../research/retained-producer-capacity.md#main-string-shape-invariant),
at lines 653–705, excludes such entities on GNATprove's semantic/light-expansion
path: nonstatic initializers return before subtype expansion, and the relevant
Actual_Subtype setters exclude ordinary named String objects. This premise
is about entities reaching the helper, not later native expansion or arbitrary
library types. It makes constrainedness and staticness coincide in this row's
domain. The note's "unconstrained target" wording therefore relies on the
imported shape proof and must not be inferred from representation alone.

Equal source/target identity returns the input without changing pending
temporaries. Otherwise the order is:

1. Apply the source's stateful temporary rule to the input child.
2. Obtain the source map, optionally slide it using the complete bound trees.
3. Wrap that map in the empty native Label and apply the temporary rule again.
4. Reconstruct an unconstrained target, or retain the split map for a static
   target.
5. Prepend the requested program-domain length or dynamic-property assertion.
6. Bind the split temporary, then the source temporary if one was introduced.

The native Label is a real constructor before projection; it requires the
second binding even though E/T conversion later removes the empty attributes.
The first temporary exists only when the input is complex or is already a
pending temporary. Cheap nonpending identifiers and dereferences remain at
every use. A pending input belongs to the caller: conversion rebinds it,
consumes its own entries, and preserves the caller's original definition.

The length term is

```text
if lf <= ll then rf <= rl /\ (ll-lf = rl-rf) else rl < rf
E0 = 8 + 2*lf + 2*ll + 3*rf + 3*rl.
```

Both static types with equal lengths elide the assertion, while retaining
the split binding. The nonstatic-target assertion is the four-argument
`dynamic_property(target_first,target_last,first(a),last(a))`. Static source
bounds remain complete supplied trees; nonstatic accessors retain their
source-child occurrences.

The retained 84 diagrams cover the declared differing-identity control
partition, including term/program mode and identifier/complex/pending inputs,
plus static-map dereferences. These are algebraic branch witnesses. Some
control combinations conservatively exceed ordinary reachable source pairs;
they are not candidate membership samples. The equal-identity and equal-static-
length branches were checked directly in source and author implementation;
they are not additional independently executed diagrams.

## Primitive and typing interface

For fully applied symbols with positive actual weights `a_i` and result `r`,
the generic value post is `2+r+sum a_i`, with definition `1+sum a_i` and
residual True. The predicate post is `4+r+sum a_i`, with Boolean definition
`4+sum a_i` and residual True. Closed post storage adds a separate epsilon.
The catalogue preserves preconditions, definition/residual trees, arities,
result sorts, module-specific binding routes and constructor reset flags.

The imported let-function body does not enlarge these per-call posts:
RKfunc/RKpred receive their logical equality/iff, whereas the empty-post body
enrichment guard applies to RKnone Cfun. Separate imported logical definitions
or axioms remain part of the broader context obligation.

The relevant non-generic distinctions are retained:

| Binding | Accepted treatment |
| --- | --- |
| Static/Dynamic scalar checks | Explicit preconditions and postcondition residuals; Dynamic has three arguments. |
| Standard Boolean checks | Smaller explicit result-equality posts. |
| Standard Boolean bool_eq/bool_ne | Opened `5+r+x+y`; definition `4+x+y`; residual True. |
| Discrete_Base bool_eq | Unsimplified conditional `7+x+y+2*r`; later simplification/extraction is unclassified here. |
| Rep_Proj_Base.to_rep/of_rep | Explicit reversed/projected result equalities; no result-first extraction. |
| Integer/Positive first/last | Nullary RKfunc calls; opened `2+r`, definition 1, residual True. |
| Mutable one-field constructors | Value-equality contract plus the constructor reset flag. |

Native domain/type annotations alone do not determine the typed expression.
Caller E/T mode controls recursion. Accessors used as program arguments retain
applications and contracts; assertion accessors are logical terms. In
particular, the native `Int.<` call in the length formula's else branch has
an integer type annotation but its resolved signature is a proposition.
The normalized record preserves that annotation while the logical projection
uses the signature and context. This is a constructor interface, not a replay
of Why3 typing or a claim of byte-exact native AST reproduction.

Program applications keep all argument occurrences and a formal contract
reference. The reviewed typing envelope is
`2+2*arity+sum E(child)`; let/sequence/if add one, and/or add two, not adds
three, and assertions have one program node plus their separate logical term.
Actual expression trees are not substituted directly into formal contracts.
Later proxy binding, extraction and effect/U/H composition remain explicit
obligations.

## Material findings and disposition

**MC1 — temporary and identity ownership.** Pre-freeze review required cheap
references to remain repeated, the empty-Label split binding to survive, and
pending input ownership to be explicit. The final code does so. Its identifier
entrypoint reserves generated `tmp:` keys and its builder verifies child
object ownership, avoiding cross-builder uid collisions. The audit checks
all views of a shared uid, pending-event consumption, generated binder scope
and preservation of the incoming map. This is not a hardening claim for raw
record construction outside the interface's premises.

**MC2 — bound trees and resolved contracts.** Pre-freeze review rejected the
assumption that a static bound is always a literal and that a native term tag
forces pure argument conversion. The final input retains bound subtrees and
symbol-identifier resolution. The supplemental scalar generator source
attaches first/last to Pterm declarations; the native retained declarations
and converter/typing route supply the nullary program-call distinction.
The module-specific scalar and projection rows above incorporate the related
contract corrections.

**MC3 — whole supplied children and monotonicity.** A supplied child handle
denotes its complete body, contracts, attached terms, effects and free/bound
identities, with an explicit binding-context obligation. The example imports
one complex child and has expression projection `24+P_source_child`; it does
not independently derive that child. The local projector remains partial for
other constructors. Monotonicity holds for positive weights with constructors,
resolution and control choices fixed. Replacing cheap syntax by complex syntax
can change sharing and reduce program occurrences, so no arbitrary-syntax
monotonicity claim is accepted.

**MC4 — target constrainedness is an applicability condition.** Final source
comparison identified the `Is_Constrained` versus `target.static` distinction
above. Inspection of the pinned capacity provider and author clarification
resolved it through the existing Main shape induction. This row must not be
generalized to dynamic constrained target entities by representation alone.
Later source callers must preserve the imported premise; no current complete-
Main claim is accepted.

MC1–MC3 were incorporated before the exact freeze. MC4 reuses an established
shape premise without replaying its successful checker. No material finding
remains within the precisely restricted tranche. The broader source callers
and Main wrapper continuation were not included in these inputs.

## Evidence and remaining obligations

The independent script imports no author or predecessor module. It pins all
nine author files, verifies 13 provider identities, reattaches all fourteen
complete copied source files, and checks 49 reviewed spans over fifteen source
members. The supplementary member is the scalar-bound generator. All ten files
of accepted fixed author `3040c6736d3a004239256b2ba50f25144e68bec8` remain
identical; review `00a37442cc2912a4a456717d33ee852facd1f2fc` is reused without
replay.

For all 43 signatures, the audit independently constructs the complete
contract, extraction and residual trees. It independently reconstructs every
conversion diagram and E/T projection, and recovers affine coefficients by
lexical evaluation at unit coordinates and mixed large positive weights.
There are 190 checked term records and 3,465 native occurrence visits across
the body/input/bound/pending views, including repeated views. Program checks
retain full child occurrences, scope, formal contract references and proxy
slots. The universal fixed-constructor affine claim follows from structural
induction and lexical substitution; finite checks support that argument.

The author's focused check reports 2,383 checks in 2.126551 seconds and no
failures. Its implementation probes were read but not independently executed.
The reviewer ran one final audit, without a failure or successful rerun.
Author freeze was imported as `0225661ec05fa9dc2bd5eab3c7a24e2e17de8062`.

Concat/comparison/Image/Length callers, declaration/assignment invariant
suffixes, observations and warning functions, range-loop captures/index/frame/
handlers, and the enclosing Main contract remain open. These must join with
proxy typing, complete effects, internal Cfun traversal and variable/outcome
accounting before source-derived U/H or #178 completion. Source/operator/leaf
counts remain symbolic; old 4096/63/64 policy ceilings are not analysis
assumptions. Fixed dependency constants keep their existing semantics.

This result alone establishes neither a useful whole-rule domain nor a cap
relaxation. Main import/alias lifetimes, preparation/terminal-goal joins,
native GCC and whole #119 composition remain separate. Existing resource,
faithful-runtime and source-correspondence assumptions, one global Why `e<=2`,
two save-entering callbacks and three saves are unchanged. No target, compiler,
solver, proof, capture or predecessor checker ran; no GitHub, shared-record,
harness-state or CLI-memory writes were made.
