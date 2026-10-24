# Main construction-demand review — bounded repaired result accepted

The repaired author freeze `3f4f6143c206518bf257d3d9b63cee2a08d14bcd` is
**accepted for its stated bounded result**. The original capture-premise
finding #211 is repaired: the generic preservation theorem has an explicit
sufficient premise, type instantiation constructs it, and actual clone-map
preservation remains conditional on a separate inherited-map induction.
The single new independent audit passed 1,446 assertions. No material finding
remains against this bounded result. Full source-to-VC construction/storage,
complete native byte demand and #202/#119 completion are not claimed.

The initial author freeze was `5d9ed9375c4db7fd92b8c7317402754c8fede354`;
provisional review `62dee518226c221e3e396a76ee5693272ee01f23` recorded the
counterexample before repair. The final audit verifies exact file equality to
the repaired author commit even though this review branch has its own history.

## R1 / #211 — confirmed and repaired

The original research note claimed that generic mapping denotes the ordinary
capture-avoiding type/symbol transformation, and attached that preservation
rule to cloning under a type-compatible, injective free-variable map.
Those conditions alone were insufficient.

Take `forall v:int. R(x,v)` and an outer map `{x -> v}` with identity type
and logic-symbol callbacks. The outer map is injective and type-compatible.
Native `gen_fresh_vsymbol` returns the original bound `v` because its type did
not change (`term.ml:1085–1088`). The body map consequently sends both original
`x` and bound `v` to `v`. The result is `forall v:int. R(v,v)`, capturing the
original free occurrence. The mapped `bv_vars` still contains `v:1`, so the
output also loses cache correctness. The weaker saved-support predicate
accepts it because the saved-image map is empty.

A narrow direct Python probe against the frozen bridge confirmed exactly
this input/output and cache behavior. The
[reproducible probe](../evidence/review-main-construction-demand-20261024/capture_probe.py)
records it; no predecessor checker or native execution was needed.

The repaired theorem requires root cached-FV coverage, injection and a
strong sufficient freshness rule: each nonidentity target lies outside all
identities in the stored input, including patterns, caches, saved keys,
bodies, triggers and every saved image. The incoming Ident history covers
both input and map identities; fresh allocation is distinct from all of them.
Correct caches and type/symbol compatibility remain separate premises.

This premise supports the source induction. At each frame, cached support
covers saved-image free variables. Every raw body/trigger free variable is
represented by that support, a saved key or a bound slot. Saved images are
mapped using the incoming map; the body uses extensions for saved keys and
bound variables. Unchanged local identities cannot equal a different incoming
nonidentity target, while fresh targets cannot collide with any prior map
range. Rebinding the same original identity intentionally shadows its outer
role in the body while preserving that role in saved-image closures. This
establishes the required coverage and capture separation without changing
native unchanged-binder behavior.

`t_subst_types` constructs the premise through `gen_mapV`. The proof wrapper
checks its structural/support part before native-recursion accounting; it is
mathematical entry validation, not a newly implemented native operation or
Silver admission rule. The repaired raw recurrence still exhibits the original
capture example, while the proof wrapper rejects it. It also rejects missing
coverage, noninjective maps and an incompatible inherited entry even after a
fresh formal is added.

The actual clone caller is now explicitly conditional. `sm_of_cl` imports
`cl.pv_table`; `sm_save_vs`, `sm_save_pv` and RLpv extend inherited maps;
`clone_cty` adds formals and oldies to that map; declaration cloning writes the
extended map back. The new source spans match `pmodule.ml:851–883,1458–1466`.
Neither fresh formals nor fresh oldies prove the required property of all
inherited entries. The note now leaves coverage/capture compatibility of the
whole history, including unchanged foreign variables, as an undischarged
clone-fold obligation. **#211's incorrect theorem/attachment claim is repaired;
that narrowing does not complete the clone-fold obligation.** No new material
issue was found in this repair.

## Completed bounded source inspection

The reviewer inspected retained source spans from `term.ml`, `ty.ml`,
`weakhtbl.ml`, `ity.ml`, `pmodule.ml` and `vc.ml`, using the complete files
in the manifest-bound archive and additional constructor/clone-map surroundings.
The accepted R83 kernel/review and source-binding scope were reused without
replaying their checks.

- The positive-cache/saved-image support induction respects restriction to
  `bv_vars`, recursive rewriting of every old saved image and left-biased
  union. Bound and free occurrences may share the same old variable identity;
  saved-image interpretation drops its owning binder frame.
- `gen_bnd_rename` maps each image with `fnE` closed over the original outer
  map, while its saved-key renaming accumulates a separate map for body and
  trigger traversal. This distinction is implemented correctly in the bridge.
- The native traversal visits every stored term occurrence once, including
  all images and triggers. It attempts freshening once per root free variable,
  saved key and binder slot. Pattern variables count once per branch's distinct
  set; every pattern node contributes a callback, including ignored pattern
  type results. Existing case/pattern syntax remains separate from the
  case-free substitution/gate domain.
- The `F` free-variable callbacks precede the public mapper's one local
  `Wty.memoize 17` wrapper. Its lookup count is `K+B+P+X+C+A`; all-miss charging
  is valid without a no-GC assumption. Each root creates a new wrapper.
  `ty_inst` returns type-variable images without revisiting them and requests
  Hsty once per old Tyapp occurrence; the bound is confined to callback work.
- `cty_apply` maps all pre/post/xpost roots, uses ordinary substitution after
  its final identity-type test, and bypasses stage 4 on its earlier trivial
  return. Prior work is retained. `clone_cty` uses `sm_args` and `sm_olds` at
  the stated rows, with actual preservation conditional on the stronger map premise.
- The open ledger correctly retains source/typing/overload attempts, native
  clone work, candidate enumeration, kode construction, both extraction
  unwinds and failed prefixes, reflow temporaries, SP/WP and the shared
  `ht_written` owner. The endpoint remains entry to `mk_vc_decl`. Native
  byte accounting for this new mapper and caller multiplicity remain open.

No additional material source/count discrepancy was identified. The author's
original 1,092-check result and repaired 1,110-check result were read, not
rerun. They and the independent audit are finite evidence, not a
machine-checked universal proof.

## Final independent audit

The [audit](../evidence/review-main-construction-demand-20261024/audit.py)
passed **1,446 assertions** in **0.763000717 seconds**. It imports only the
bridge and accepted kernel; it does not import or execute an author or
predecessor checker. Its independently written eager environment interpreter
compares stored-image/type-substitution semantics across 120 constructive
diagrams with nested saved images, dead keys, triggers, concrete and changing
types, intentional bound/free identity sharing and ordinary term forms.

An independent census predicts stored-term visits, saved-image visits,
pattern visits, freshening attempts, exactly the changed-type Ident increments,
all outer type callbacks, the pre-wrapper/memoized split and old-Tyapp all-miss
Hsty demand. It covers 3,396 stored visits, 590 saved images and 1,459 freshening
attempts in the generated diagrams. Focused cases exercise all five pattern
forms, repeated Por variables, a saved image in a case branch, original outer
mapping, the capture regression and valid fresh external mapping.

The call-contract fixture has five pre/post/xpost roots sharing one Ident
owner: five independent type-map tables and ten increments. Its same-type
branch creates neither generic-map tables nor fresh variables. Case-bearing
terms remain excluded from composed substitution. Rejected proof premises
produce no recorded native callbacks or fresh demand.

Input checks bind all nine final author files, four providers, one source
archive, eight complete source files, 19 exact spans and 49 source anchors.
The author files remained unchanged after the audit. These checks establish
input correspondence; the reviewed source induction supplies the general
mathematical claim under its stated premises. Native byte demand and actual
clone/source caller closure remain outside the result.

## Review identity and handoff

Selected reviewer setting: **GPT-6 Astra / Extra High** in both rounds.
Runtime model/effort confirmation, token counts and cost were unavailable.
The initial recorded source-review interval was 04:18:05–04:20:31 UTC on
2026-10-24 (146 seconds), excluding setup and later report/commit work. Its
one narrow direct probe took 0.018841701 seconds of tool wall time. The repaired
review/audit interval was 04:28:30–04:31:28 UTC (178 seconds), excluding later
report/commit work. Final audit tool wall time was 0.835741231 seconds,
distinct from its internal 0.763000717-second measurement. Neither interval
is whole-team elapsed time or cost.

The [receipt](../evidence/review-main-construction-demand-20261024/receipt.json)
preserves the initial checkpoint and binds the final inputs and disposition;
the [audit result](../evidence/review-main-construction-demand-20261024/audit-result.json)
records its exact families. Linux is the observed host. The live harness goal
read was null. There was one successful final audit and no failed final audit.
No native target, compiler/prover, author/predecessor checker replay, goal
write, GitHub write or CLI-memory update occurred in this review.

No Oracle, language admission, tool/source pin, production #88–#94 work or
#206 configuration change is introduced. Parent handles integration,
publication and finding/issue disposition. The review commit modifies only
this report and its evidence packet; author-repair content is unchanged.

| Round | Selected setting | Intended result | Result / rework | Evidence |
| --- | --- | --- | --- | --- |
| Original frozen bridge | GPT-6 Astra / Extra High; runtime unconfirmed | Challenge stored scopes, counts and caller attachment | R1/#211 confirmed; author repair requested | 146 s recorded interval; one 0.018841701 s probe; tokens/cost unavailable |
| Repaired exact freeze | GPT-6 Astra / Extra High; runtime unconfirmed | Verify stronger premise and explicit clone boundary | Bounded theorem accepted; full clone/caller/native-byte closure remains open | 178 s recorded interval; one 1,446-assertion audit in 0.763000717 s; tokens/cost unavailable |
