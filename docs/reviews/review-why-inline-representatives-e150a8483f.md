# Independent review: returned-representative interface correction

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119),
scope correction [#133](https://github.com/berkeleynerd/silver/issues/133).

**Disposition: scoped acceptance; no new material finding.** The repair
corrects the operational packet's established-transfer overclaim. Stored and
semantic-dependent totals now require an explicit, uninstantiated contract
for declarations returned by hashcons. Numeric hypotheses cannot supply that
coverage. This accepts the #133 interface correction, not an actual native
representative envelope or a completed local/preparation capacity argument.

## Frozen inputs and scope

Reviewed commit: `e150a8483fd8f195c53f55cd895212ae4e39d795`, whose parent is
`b68756eea4daae31f221eb72eefb9d40665d7b70`. Review used the initially clean
isolated branch `review/why-inline-representatives-e150a8483f`. The target
worktree was not edited; this report is the sole owned file.

The exact correction comprises the
[research note](../research/retained-why-inline-operations.md) and these files
in the [packet](../evidence/retained-why-inline-operations-20261018/README.md):
`README.md`, `compose.py`, `check.py`, `inventory.py`, `representatives.py`,
`result.json` and `round-repair.json`. I also inspected the retained manifest,
inventory, original round and source identities needed to distinguish changed
claims from reused evidence.

This is a bounded follow-up to the
[original review at `78db8ca58e`](https://github.com/berkeleynerd/silver/blob/78db8ca58e6fe68d28cf5f350d859d03e8f1796b/docs/reviews/review-why-inline-operations-b68756eea4.md).
Its source argument and counterexample are reused. The accepted entry
`7c89b21e2489d984bdabcae3d5bd88a6dd38e2b8` and semantic model
`35098484475dbb2da7a0e663194c2251abb8d1a1` remain input evidence with their
existing limits. Applicable AGENTS/Oracle and review bookkeeping were reused;
AGENTS and Oracle have no change between the two operational freezes. The
live child goal was null.

Why3 remains at `9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml at
`8eb41f72ded84df884c3671734c947f612091f84`. The complete retained source
archive, input manifest and captured inventory are byte-identical to the
original operational packet. The source archive remains 103,401 bytes,
SHA-256 `1c33b259040cee14ba1c9babd10ae223fb66a06a560629794b432d069328dd07`.
No capture or native source/runtime correspondence audit was repeated.

## Why the correction is sufficient for its stated endpoint

1. **The returned object is explicitly part of the missing input.**
   `representatives.py` quantifies over every old live declaration a local
   `Decl.Hsdecl` merge can return, including earlier local insertions. Its
   coverage requirement calls for a complete initial projection or a
   source/process invariant joined to merge/return sites, closure under local
   insertions and weak clearing, and exclusion of concurrent foreign
   insertions. Unused values, key identifiers, types, attributes and repeated
   stored edges are included. Neither the captured root inventory nor a
   sample of selected objects is presented as this evidence.

2. **Four numeric fields cannot stand in for the semantic obligations.**
   `E,V,T,A` bound saved entries, saved-value occurrences, type occurrences
   and the attribute universe. The separate required invariants cover valid
   graphs/caches/counts, noncolliding identities, binder-free unary saved
   values, cross-map nonunit-key disjointness, symbol/signature closure and
   declaration/binder shape. These are the conditions needed to reuse the
   original local derivation; the interface does not claim to have checked
   them on the shared table.

   In particular, the contract requires correspondence at the declaration
   index after **real opening and `t_attr_copy`**, preserving types, constants,
   triggers, patterns, multiplicities and eligibility-relevant attributes.
   It allows additional guard exclusions as optional misses but forbids extra
   eligible bodies or hits outside the accepted 45-body/85-hit alternatives.
   This addresses the fact that strict frame-based comparison alone does not
   establish the opened `notdef`/`notls` decision. The note now distinguishes
   the accepted semantic model from its unresolved runtime attachment.

3. **All dependent totals have conditional status in the actual output.**
   The four former top-level groups `structural`, `events`, `shared_groups`
   and `fresh_groups` now occur under `conditional_arithmetic`, whose status
   is `conditional_on_uninstantiated_representative_contract`. This includes
   the 36/50 map bounds, 21,483 stored occurrences, 88,982,586 hidden entries,
   52,907,301,372 free-variable scan entries, 8,292,438 validator entries,
   **1,145 identifier increments**, **669 type requests**, hit memo tables
   and full validator/termination work. Keeping these numbers does not claim
   that their native attachment has been established.

   Both default and supplied hypotheses leave
   `actual_representative_envelope = null`, contract coverage evidence null,
   contract status uninstantiated, and the local established flag false.
   Complete-transform, shared-state, all-pair and whole-pipeline flags also
   remain false. No function parameter accepts a coverage verdict.
   `numeric_hypothesis` requires exactly the four numeric keys and exact
   integer types, excluding Booleans and extra caller approval fields.

4. **A larger hypothesis changes downstream arithmetic.**
   `compose` uses the componentwise maximum of the captured baseline and the
   supplied hypothesis. With `E*=max(8,E)` and `P=14`, the delayed and opening
   map bounds become `E*+2*P` and `E*+3*P`; stored mass becomes
   `99*(1+(E*+2*P)*max(6,V))`. Hidden substitutions, free-variable scans and
   validator folds use that stored mass. Type work uses `max(3,T)` and its
   square, while attribute/map bounds include `max(80,A)`. The new checks
   exercise `(E,V,T,A)=(37,9,5,4000)` and still require missing coverage to
   leave the established result false. The default `(8,6,3,80)` is consistently
   described as a hypothesis, not a projection of the old table.

5. **The returned-old regression exercises the downstream path.**
   `returned_old_map_witness` first builds the growing saved map by the
   variable-only specialization of `bv_subst_unsafe`. It compares the opened
   alpha key with a clean candidate, selects the old representation, then
   opens the outer formal and folds the selected representation's saved
   values. The 37- and 128-step cases therefore have 38 and 129 downstream
   saved-value visits, rather than the clean candidate's one new renaming.
   This would expose accidentally using the candidate map for that modeled
   downstream work. It is a meaningful source-rule regression, not a native
   weak-table implementation test, exhaustive semantic proof or observation
   of the captured process. Those limitations are stated in code and prose.

6. **Reusable selection-independent results stay separate.**
   The topological request group retains 143 declaration, 244 theory, 512 task
   and 17,152 Patricia requests, plus the fresh fold/metadata cache bounds.
   Its fixed-spine/valid-table/no-foreign-insertion premise and its exclusion
   of callback work and initial counter states are explicit. It does not
   contain the conditional identifier or type request totals. The pure
   counter, Weak and Ephemeron transfers are unchanged. Their existing
   initial-state and representation conditions remain requirements.

The README, research note, output statuses and repair-round record agree on
this endpoint. The original `round.json` is clearly identified as historical
evidence containing the superseded claim. No current document in the reviewed
correction promotes the conditional totals to established native bounds.

## Evidence and remaining obligation

I reused the author's successful focused repair check, recorded in
`round-repair.json` as **0.354466 seconds**. I read the changed checks for
returned-old traversal, larger-envelope propagation, missing coverage and
Boolean/extra-field rejection. I did not rerun that successful replay, the
predecessor suite or the original native capture.

One independent, read-only audit passed in **0.038827 seconds**. It compared
the old and repaired frozen JSON directly and confirmed that all four former
operational groups were moved intact under conditional status, with none
remaining at the root. It checked the null/false coverage and completion
fields, byte identity of `inventory.json`, `inputs.json` and `sources.tar.gz`,
and AST identity of the three pure table/counter transfer functions. It also
checked that the independent request group omits identifier/type totals and
retains its callback/initial-state limitation. This was a focused interface
and evidence-reuse audit, not another composition replay.

The retained graph covers 244 task declaration roots, not the shared
`Hsdecl` table. To establish the contract, #119 still needs the complete live
selectable-representative projection joined to the actual weak-table
representation, or an adequate source/process invariant. It must discharge
local-insertion closure, absence of foreign concurrent insertion, the
stored-value/type/attribute restrictions and actual opened-body/eligibility
correspondence. Initial counters/backing, unsuccessful-comparand costs,
runtime allocation/collection composition, other entries and later consumers
remain separate required obligations. This review neither supplies those
inputs nor weakens their necessity.

## Review round record

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the parent.
Independent runtime model/effort confirmation and token/cost measurements are
unavailable. Review host: Linux 7.0.14, x86_64. New native capture, compiler,
prover, debugger, server, solver, build, proof and full-suite runs: **zero**.
No target edit, GitHub write, additional reviewer or CLI-memory update occurred.
The parent owns integration, publication, issue status and durable memory.

Intended outcome: verify that #133's missing representative input becomes an
explicit conditional contract and that every dependent claim respects it.
Achieved outcome: scoped acceptance of that interface correction; no material
rework requested. Local links and the staged diff were checked before commit.
Review timing below excludes commit and parent integration/publication.

Review interval: `2026-10-18 21:23:25 UTC` to `2026-10-18 21:25:49 UTC`,
144 seconds through report preparation and local-link checks.
