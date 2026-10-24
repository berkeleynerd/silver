# Main construction-demand review — author repair required

The review of author freeze `5d9ed9375c4db7fd92b8c7317402754c8fede354`
found **one material premise gap**. The stored type-instantiation recurrences
and source call-dispatch rows otherwise match the retained source within their
stated bounded scope. Acceptance and the final independent audit remain
pending author repair. This is not completion of #202 or #119.

## R1 — an injective variable map can capture a free variable

The research note claims that generic mapping denotes the ordinary
capture-avoiding type/symbol transformation, and attaches that preservation
rule to cloning under a type-compatible, injective free-variable map.
Those conditions alone are insufficient.

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

Required disposition: state a capture-compatible variable-map premise,
including coverage of cached supports, and explain how it is preserved through
saved-key and binder extension. The `t_subst_types` entry constructs its map
from every root free variable using unchanged identities or globally fresh
symbols, which supplies more than arbitrary injection. For the clone entry,
attach the needed freshness/disjointness to actual clone construction,
including inherited `sm.sm_vs`; otherwise keep that caller's preservation
conditional with the exact remaining obligation. Fresh formal/old symbols
alone do not establish a property of every inherited map. Do not silently
change the native generic mapper to freshen every unchanged binder. A negative
or rejection regression should preserve the counterexample's lesson.

The lead confirmed R1 for disposition and will return this bounded task to
the original author. No repair has been reviewed at this checkpoint.

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
  the stated rows, subject to R1's stronger map premise.
- The open ledger correctly retains source/typing/overload attempts, native
  clone work, candidate enumeration, kode construction, both extraction
  unwinds and failed prefixes, reflow temporaries, SP/WP and the shared
  `ht_written` owner. The endpoint remains entry to `mk_vc_decl`. Native
  byte accounting for this new mapper and caller multiplicity remain open.

No additional material source/count discrepancy was identified in this
inspection. The author's 1,092 checks are retained finite evidence and are
not a machine-checked universal proof. They were read, not rerun.

## Review identity and next check

Selected reviewer setting: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, token counts and cost were unavailable. The first recorded
clock was 04:18:05 UTC and the source-review checkpoint was 04:20:31 UTC on
2026-10-24: 146 seconds, excluding initial setup and later report/commit work.
The narrow direct probe's tool wall time was 0.018841701 seconds. The
[receipt](../evidence/review-main-construction-demand-20261024/receipt.json)
binds the frozen inputs and distinguishes this source inspection from the
still-pending final audit. Linux is the observed host.

One new focused independent audit remains authorized after repair. Native
runs, predecessor-checker replays, CLI-memory writes and final-audit runs are
all zero at this checkpoint. No Oracle, language admission, tool/source pin,
production #88–#94 work or #206 configuration change is introduced.

| Round | Selected setting | Intended result | Result / rework | Evidence |
| --- | --- | --- | --- | --- |
| Frozen bridge source review | GPT-6 Astra / Extra High; runtime unconfirmed | Challenge stored scopes, request multiplicities and caller attachment | R1 capture-premise repair required; other bounded rows inspected | 146 s recorded source-review interval; one 0.018841701 s probe; tokens/cost unavailable |
