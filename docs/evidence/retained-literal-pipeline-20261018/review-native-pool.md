# Independent native pool and symbol lifetime review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted for the stated conditional native pool/shared-tree interface, with no
unresolved material finding. Whole native and literal-pipeline capacity remain
open, including the next call-edge, IPA-summary and collector composition.

The frozen review target was `868f120cf9c25c8ce35b2e495e1c04fe23e9dce6`.
The reviewer also checked correction
`67798e0ab8e1a4500ed3ee3b6b417a31e2296582` against its parent. The intervening
producer-specialization integration was outside this native review; an AST
comparison confirmed `native_pool_lifetime` was unchanged between the frozen
target and corrected target.

Reviewer selection: GPT-6 Astra, Extra High, explicitly selected by the parent;
no independent runtime confirmation is available. The measured review/check
window was 17:51:47–17:55:54 UTC (247 seconds), excluding report authoring.
Token and cost measurements are unavailable. This was offline source review
and Python arithmetic on the Linux workspace; no native executable, compiler,
prover, build, suite or new prefix capture ran.

Inputs were the literal-pipeline source argument, callable, checker, descriptor,
both input manifests and retained results; the relevant fixed-prefix,
symbol-ingress, direct-pool and selected-IPA predecessor arguments/evidence;
and their retained GCC/Ada sources. Focused source inspection covered Cstand
roots and freezing, gigi metadata/dependency ingress, constant descriptors and
hash traits, varpool analysis/removal, cgraph analysis/expansion, pass scheduling,
inline reference clearing, initializer walking/canonicalization, symbol/name
registration, reference vectors and hash growth. Source roots were the retained
GCC tree at `/tmp/silver-backend-compose-20261018/full-source`, Ada tree at
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, and selected
GNAT 16.1.0 plugin headers named by the packet. This does not re-review the
entire compiler or replace the existing source-behavior and Main-preservation
premises.

The original explanation said bounds references persist “throughout.” Actual
early inline and the queued inline transform clear Main's reference list.
Correction `67798e0ab8` replaces that overstatement with the relevant intervals:
the scheduled rebuilding restores references before IPA unreachable-node
removal; final transform clearing occurs during expansion afterward. The
actual expansion route uses `get_untransformed_body`, so `get_body`'s extra
rebuild is excluded by its selected PTA/SIMD callers. The correction adds
the two newly required source identities, independently checked against the
retained files. This was a source-explanation/attachment correction, with no
required arithmetic change.

The following conclusions survived the source checks:

- The 39,257-event witness transfers only the fixed relevant prefix, with
  metadata separately bounded and excluded from pool insertion. Charging all
  those events to possible descriptors conservatively gives `D_in=39257`;
  the source growth rule gives incoming capacity at most 131,071. This is
  neither observed occupancy nor a transferred null whole-lifetime bound.
- The selected post-prefix dependency route adds no uncharged pool root.
  Bounds finalization creates at most C varpool nodes. Each initializer walk
  visits at most its constructor and two integer values, producing no outgoing
  references and needing only the initial 13-slot ordinary visited-node table.
- Four graph scans bound reference creations; the two reference-clearing
  intervals add no scan. The descriptor table uses strong `ggc_ptr_hash`, so
  it is not a weak cache that silently loses descriptors during collection.
  After final transform clearing, variable cleanup follows expansion
  (`cgraphunit.cc:2430–2440`); emitted bounds are retained by `DECL_RTL_SET_P`
  or `no_reorder` (`varpool.cc:645–653,700–708`). No repeated gimplification or
  bounds-node recreation is selected.
- The tree hash pays pre-hit replacement work, the assembler hash pays cold
  control/backing and at most one insertion per selected symbol, and reference
  vectors retain their capacity/intermediate/signed-traversal checks. The
  resulting `5C+5` GGC-event delta excludes the already charged direct `10C`
  objects and fixed symbol nodes. It is an increment, not a complete lifetime
  or simultaneous-memory bound.

The independent offline checker passed all 21 cases and reproduced retained
`check-results.json` exactly. Outputs went only to `/tmp`. The checker validates
source attachment, arithmetic and explicit open scope; these passing cases do
not themselves establish the universal source argument. No additional native
or proof execution was needed to verify the explanation-only correction.
