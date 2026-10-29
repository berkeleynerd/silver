# Named Integer subtypes and bounded array components

Status: implementation and assurance integration in progress; not yet supported. [Milestone 13](https://github.com/berkeleynerd/silver/milestone/13)
contains one coherent work package, [#286](https://github.com/berkeleynerd/silver/issues/286).
The [2026-10-29 authorization](session-memory.md#2026-10-29--named-integer-subtypes-and-bounded-array-components-authorized)
covers implementation through complete assurance, validation, independent review
and feature PR publication. The feature PR remains subject to the owner's merge
instruction.

## Selected scope

The driver is Rosetta [Sum of squares](../rosetta/s/sum-of-squares/task.wiki).
The proposed declaration is `subtype S is Integer range staticLo .. staticHi;`.
Require nonempty static bounds contained in Integer, and permit earlier named
subtypes in initialized scalar objects and the component indication of existing
anonymous fixed arrays. Subtype declarations name Integer directly; subtype alias
chains remain excluded. An optional scalar object-local range may further narrow
the named subtype to a nonempty subset. Preserve the inherited Ada/SPARK meaning: a subtype
constrains Integer values; it does not create a distinct Integer type.

Every initialized or subsequently stored value must respect its declared subtype.
The declared component bounds inform array reads and constant-array foreach
body reasoning, so arithmetic such as a bounded component square can be admitted
without silently widening the component to the full Integer interval. Establish
these invariants for every permitted composition, including existing guards,
scalar and indexed assignment, loops and name hiding. Preserve the author's
actual source bytes through proof and build.

Retain the current 4,096-byte source, 63-operator and 64-leaf budgets, existing
array index rules and constant-iterable restriction. Conversions, derived types,
functions/procedures, dynamic bounds and general arrays are outside this package.
This proposal admits no syntax until implementation and required assurance are
complete; current support remains defined by [language.md](../language.md).

## Design and completion obligations

Settle the exact static-bound grammar, declaration identity/order and visibility,
scalar initializer/assignment rules, component interval propagation and permitted
compositions before declaring support. Inspect actual native producer obligations
and any new report routes, advisories or feature-local report-capacity effects.
An accepted obligation class needs its semantic and automatic-discharge argument;
report acceptance and passing examples alone do not establish that guarantee.

Extend native Bronze/Silver verification and Lean decidable membership,
composition, semantic preservation, termination, automatic-discharge and
actual-source correspondence across the resulting admitted language. Reuse
applicable existing proofs and evidence while discharging every newly affected
obligation. Keep the Oracle and trusted-boundary claims accurate; do not suppress
checks or narrow domains to make proof succeed.

Add boundary, rejection and interaction regressions and a faithful Sum of squares
sample. Update language, catalogue, sample manifest, capability and roadmap
records together. Reconcile the exact fragment with broad stages #11/#12 in the
Rosetta assessment, supported identifiers, current-language description and
rendered progression. Their broad remaining scope stays Open/Backlog.

Complete the required native proof/coverage/provenance, build, Lean/source/module/
axiom and full regression validation on identified final inputs, followed by
independent review and feature PR publication. No validation or assurance result
is claimed by this initial planning record.

## Work round

Authorization recording used selected GPT-6.1 Sol / High for this bounded planning
subthread. Runtime model confirmation and token/cost measurements are unavailable.
The deliverable is the authorization-only planning PR and one milestone/package;
feature design, implementation, proofs and validation belong to #286.

## Implementation decisions and current checks

Subtype declarations use a separate compact metadata table, preserving existing
scalar cell identities and static-value invariants. Five operation-hiding flags
enter recursive body contexts; the whole subtype table stays in declaration
state. The source-derived subtype capacity is `4096 / 32`, from the shortest
accepted declaration. Scalar capacity becomes `4096 / 7` because `A:S:=0;` is
seven bytes; String capacity stays `4096 / 12`, and array capacity stays
`4096 / 24` (the shortest complete new array declaration is 25 bytes).

Array descriptors carry declared component intervals. Initialization and writes
must establish interval containment; reads and constant-array iteration use that
interval. Ordered, disjoint array allocation and initialized-value containment
are explicit proof obligations. They cannot be assumed for arbitrary native
metadata merely because actual source allocation is ordered.

The native draft builds. Managed build `20261029T144300-6c3cefd20c62` rebuilt the
compiler in the reused regression workspace `tmp/constant-array-iteration` on
branch `validation/named-integer-subtypes`, preserving the preceding delivery's
branch and retained records. Run `20261029T144520-fb1a3732d7f3` passed all ten new
subtype tests in 61.773 s, including native proof/build/execution for snapshots,
narrow stores, nested loops, argument composition and contradictory guards.
The separate Sum of squares driver has independently derived expected lines
`0` and `133`; Sum and product expects `55` and `3628800`.

Focused Lean checks have proved the component semantics, ordered metadata/read
model, complete predicate grammar, and lower native helper/adapter chain with
fresh axiom audits. These are partial checks, not a delivery claim. The new typed
source trees have passed mechanical render comparisons; the interpreted helper
proofs and complete authoritative-source checkpoint remain in progress.

The first deepest foreach probe under 8 MiB exposed a larger native stack frame.
The native repair removed a redundant binding-array copy. The retained
[stack observations](evidence/named-integer-subtypes-20261029/stack/README.md)
now pass admission, compilation and execution for 4,096-byte programs with
158 singleton foreach levels, 141 counted-loop levels and 208 conditional levels
under an actual 8 MiB process stack. An earlier two-element foreach probe passed
admission and compilation but its exponential execution was terminated; its
interrupted outcome remains separate. No source limit or environmental stack
assumption has been changed.

| Round | Selected settings | Result and remaining work |
| --- | --- | --- |
| Native implementation, producer and resource checks | GPT-6 Astra / Extra High | Draft build, producer-route review and three bounded 8 MiB execution observations passed; compiler proof and complete audit remain pending. |
| Array semantic proofs | GPT-6 Astra / Extra High | Core component and ordered-metadata checkpoints and the complete predicate grammar passed focused audits; actual-source checkpoint remains. |
| Tests, specification, catalogue and driver | GPT-6.1 Sol / Extra High | Eight admission methods passed in 2.836 s; native integration and delivery rendering remain. |
| Declaration and source correspondence | GPT-6 Astra / Extra High | Subtype declarations, lexical domains and concrete changed model equations passed focused audits. Interpreted helper integration remains; no complete-source result claimed. |
| Integration and focused regression round | Lead settings unavailable in resumed context | Ten subtype tests passed; Rosetta metadata prepared for two drivers; typed helper proof repair continues. Shared successful ScalarDenotations artifacts are reused after source/tool/dependency comparison, with ordinary Lake rehash and fresh audits. |

Runtime settings and token/cost measurements are not independently available.
The integration proof workspace reuses a copied complete Lake artifact family
from `tmp/constant-array-source`, whose final successful baseline is run
`20261029T084327-720db926b71b` in the preceding delivery packet. The managed runner
synchronizes source inputs and freshly audits each selected import closure;
this is ordinary incremental reuse, not a clean build or kernel replay.

The [bounded tests and driver review](reviews/review-named-integer-subtypes-tests-1b3596b521.md)
found one minor record correction: the String-initializer paragraph had described
the enlarged scalar capacity as generic binding storage. The specification now
distinguishes the unchanged 341 String slots from 585 scalar slots. No test or
driver defect was found in that slice. Managed driver run
`20261029T145959-ad36e50b8dc3` separately admitted, proved, compiled and executed
both new samples with byte-identical source and the exact manifest outputs.
The run and its retained workspaces remain local pending the final packet.

The [critical correspondence review](reviews/review-named-integer-subtypes-critical-4224e6caf2.md)
found no actionable mismatch in the changed expression trees, precedence guards
or native domains at `4224e6caf2`. Its capacity/annotation follow-up confirmed
the 31,822,336-byte Main envelope and the ghost-only visibility equality repair.
It found a stale capacity regression using the predecessor's `/13` declaration
allowance; [#288](https://github.com/berkeleynerd/silver/issues/288) records the
`/7` correction in `ad2bb41d47`. Managed run
`20261029T153154-c4df9862d2d0` passed all three capacity tests. The same review
corrected an evidence-summary error: the focused native report contains 50
warning entries, not zero; its original report is preserved and the categories
are disclosed in the [annotation record](evidence/named-integer-subtypes-20261029/native-logical-equality/README.md).

That annotation repair passed focused native run `20261029T151702-6fc5f2e5c88c`:
both targeted logical-equality obligations and 287 unit flow checks passed.
This restricted check is not a complete native audit. Build
`20261029T153109-c0a06d180fd0` rebuilt the compiler after the repair. The five
changed generated certificates and the reviewed output pin were refreshed with
the actual source change; run `20261029T153446-d943972d9cb8` confirms byte parity
for all 28 certificates. Kernel checking of the final authoritative-source
closure remains outstanding.

Helper interpretation run `20261029T152349-f75d7ed9d693` passed the focused
`Silver.ComposeHelperEquations` build and a fresh 10,591-declaration axiom audit.
The repair normalizes Boolean conditions and local aliases without changing
the theorem statements or endpoint premises. Its retained preceding attempts
remain failed. Array/composition callers and the shared Sequence model are the
next focused checks, before complete assurance and the full regression suite.

| Round | Selected settings | Result and remaining work |
| --- | --- | --- |
| Helper normalization, native annotation and capacity follow-up | Lead runtime settings unavailable; native worker and independent reviewer selected GPT-6 Astra / Extra High | Helper build 365.821 s plus fresh audit 43.968 s passed; native restricted check 507.443 s passed its two proof and 287 flow checks. Capacity regression 3/3 and certificate parity passed. Complete checkpoints remain pending; token/cost measurements unavailable. |
