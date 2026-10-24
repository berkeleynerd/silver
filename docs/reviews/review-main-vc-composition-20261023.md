# Ordinary Main source-to-terminal composition review

2026-10-23–24. Independent review for [#185](https://github.com/berkeleynerd/silver/issues/185),
under #119. **Accepted** at author freeze
[`59e4ff13433b6c3ee3b1dc3888896db416682b1d`](https://github.com/berkeleynerd/silver/commit/59e4ff13433b6c3ee3b1dc3888896db416682b1d).
No unresolved material finding remains within this increment.

Reviewer selection: GPT-6 Astra / Extra High. Runtime confirmation and
token/cost telemetry are unavailable. The early review's first interval was
not measured; its retained clock starts at 2026-10-23 23:47:04 UTC. Exact
input hashes and the final audit's timing belong to the
[audit result](../evidence/review-main-vc-composition-20261023/result.json) and
[round record](../evidence/review-main-vc-composition-20261023/round.json).

## Scope and reused results

Review the composition of accepted ordinary Main typed occurrences, actuals,
contracts, effects and U/H through structured kode, reflow and SP/WP to the
initial formula, then derive its actual alias and marked-definition maps and
apply the accepted terminal transfer. The #178 acceptance at
`6031a189e04b710a2858823b9e38165838a37079` remains an input. This review does
not reopen its source inventories or replay successful predecessor checkers.

The author worked from `c5062a4452` in `tmp/main-vc-composition-20261023`.
Early review examined the uncommitted research note and focused model; the
final audit pins seven packet files to the accepted commit and checks the
author result's model/checker/identity attachments. The reviewer owns only
this report and its evidence directory in `tmp/review-main-vc-composition-20261023`.

No compiler, native Why3, prover, Lean, or production admission run is part
of this review. Oracle guarantees, tool pins and invocation, source admission,
the global `e<=2` allowance, physical resource premises and the parent's
remaining whole-process obligations are unchanged.

## Findings and disposition

1. **Marked-map traversal order.** `Task.task_fold` applies its callback to
   the newest declaration before recursing to `task_prev`
   (`task.ml:225–226`). With `Mls.add` in `gnat_split_conj.fold`, the earliest
   accepted source declaration wins duplicate symbol identities. The initial
   draft described a forward overwrite and the model iterated declarations
   forward. **Repaired and independently verified** with 48 permutations of
   source-ordered Dlogic/axiom entries and actual task-prefix snapshots.
2. **Pretty-label lookup skips quantifier triggers.** The native guard opens
   only a quantifier's body. The initial generic model recursion could find
   a label only in a trigger and incorrectly admit the definition. The
   correction retains a trigger-only negative fixture. **Repaired and
   independently verified**, together with root/body positives and the
   existing application-argument exclusion.
3. **Boolean True recognition ignores attributes.** Native `is_true` checks
   the node and logical symbol. The initial `b == BTRUE` fixture comparison
   also compared attributes, incorrectly skipping the Boolean-axiom wrapper
   for annotated True. **Repaired and independently verified** for three
   attribute sets.
4. **Source-dependent nullary declarations can construct VCs.** A nullary
   Pterm uses RKfunc; an undefined nullary Pred uses RKpred. Unlike an
   ordinary zero-arity RKnone binding, `Dexpr.let_defn:1817–1833` wraps its
   Eexec(Cany) in Cfun. `Vc.vc` therefore constructs a candidate formula.
   Treating every abstract declaration as VC-free would omit this family.
   **Repaired and independently verified:** j now includes all these
   candidates before actual native triviality/attribute filtering. Any
   retained formula enters the sum with its own known-map/prefix snapshot.
   Their exports include `U_i<=U_i0+2`, `Delta_i=0`, `B_i<=7` and
   `B_reflow_i<=23`. Their discarded formulas and construction requests
   remain in the parent's lifetime account.

The author was also asked to make the following correspondence operations
explicit: the post-matcher constant range-projection simplification; the
ordinary source guards excluding white-box calls and expression-level WP
attributes; goal-prefix capture before insertion of the original program
declaration; import flattening, lemma-to-axiom conversion and dropped imported
goals; and alias eligibility on declared signature types before occurrence
instantiation. These operations are now explicit and source-correct in the
accepted freeze. The repeated-formal fixture was also strengthened so its
weighted definition arm distinguishes first from last binding; the original
fixture's constructor arm dominated both. These are targeted corrections of
this new interface, not new requirements on #178.

## Accepted composition and limits

The construction retains lexical definitions and both `term_of_kode` outputs,
actual outcome/read/write maps, the distinct special/general SP sequence
branches and internal Cfun checks inside the enclosing Kpar. Free-variable
closure and the post-matcher constant range-projection pass are included at
their actual stages. The source-derived frontend guard premise is preserved;
no arbitrary typed-tree or coefficient certificate replaces it.

The source-dependent declaration dispatch now closes the extra-VC edge.
Native types have no invariants/witnesses; generated callable lemmas use
`vc:false`; native clones lack program-routine substitutions and their reached
type origins have no invariant refinement VC. Ordinary GNAT type-check paths
are excluded by the accepted source frontier. Explicit Goal/Exception cases
are classified. The retained fixed startup and fixed-library body processes
remain separate from this variable Main family.

The context fold derives actual typed declaration values using the retained
constructor rules, including Pdecl's logical-definition/post-axiom selection,
clone substitutions and identity-based use deduplication. It does not promote
old lexical import counts into typed values. Known_j is captured before the
original pdecl is added; D_j comes from the actual goal prefix, including
imported lemma conversion, omitted imported goals and reverse task traversal.
Alias eligibility uses declared signature types before occurrence-level
instantiation. The finite alias/constructor worklist covers matcher lookups;
one-level marked bodies use E0 without another matcher/unfold recursion.

These inputs support the accepted transfer

```text
G_source-dependent_Main <= sum_j 6*M0(f_j)^2*M1(f_j,D_j,I_j).
```

The result is a source/configuration mathematical interface under the
established tool/type/runtime premises. It does not establish complete native
finite-counter safety, every producer/consumer representation, fixed-library
#153 coverage, a useful-domain comparison or complete #119. Mathematical
integers and the explicit parent counter/representation conditions remain
distinct; retained formula sizes do not bound discarded construction requests.

## Verification and reviewer rework

The independent [audit](../evidence/review-main-vc-composition-20261023/audit.py)
passed **1,619 checks in 0.556149921 seconds** on Linux x86_64. It checks ten
complete changed-seam source identities and 22 independently selected guards,
map ordering/import/attribute cases, declared-type alias selection, lexical
meaning and scope for both extraction outputs, helper-candidate exports, and
700 well-scoped reflow fixtures in two initial modes. The retained author
result is separate: **32,574 assertions in 3.500772810 seconds**. Neither the
author checker nor successful predecessor checkers were replayed by this review.

One reviewer-only fixture required repair before the successful audit: the
initial random reflow generator reused positive outcome labels and allowed a
handler to emit its own catching label. That violates the construction's fresh
label/outer-xmap invariant and produced a spurious trace mismatch. The corrected
generator gives every positive catch a fresh label and exposes it only to the
protected child. Two failed diagnostic invocations are recorded in the round
record; they are not an author finding. A final changed-input check made the
reviewer's synthetic Boolean/polymorphic/reference fixtures consistently typed;
the preceding successful receipt is retained separately. Finite probes supplement the source
construction review and do not replace its universal argument.
