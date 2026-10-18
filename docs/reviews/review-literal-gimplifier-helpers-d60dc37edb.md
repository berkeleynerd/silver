# Literal gimplifier helper review and binding correction

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Helper review target: worker `d60dc37edbc1fbb66be52759f8e1b6ad42457821`,
integrated as `61242e0638d60073ac45d51f155c36875497a215`.
The primary agent reviewed the added helper argument independently of its
author. The 6C selected-site interface is accepted within its stated scope.
The concurrent ingress investigation found an inherited binding-count gap,
tracked as [#130](https://github.com/berkeleynerd/silver/issues/130) and
corrected in the accompanying aggregate changes. Complete gimplifier and
whole-pipeline capacity remain unestablished.

The [argument](../research/retained-literal-pipeline.md#selected-gimplifier-helpers-and-the-ingress-obstruction)
and callable charge two copied CONSTRUCTOR nodes, two copied element vectors,
one copied bounds address and one replacement pool address per literal call.
Inspected `gimplify.cc:683–711,944–973,20744–20775`,
`tree-inline.cc:5735–5795`, `tree-core.h:1636–1648` and
`vec.h:731–740,999–1016`. Copying each two-element constructor vector first
reserves four pairs: 72 bytes before GC rounding, conservatively 128 after
rounding. The data-address subtree is expressly excluded from this subtotal.

Inspected `trans.cc:9339–9354`, `utils.cc:4876–4905`,
`utils2.cc:1671–1734`, `varasm.cc:3582–3610,3721–3747,3989–3996`,
`tree.cc:7198–7264` and `fold-const.cc:2633–2640,9150–9200` for the
bounds-address route. Pool constructor comparison requires identical record
type, the declaration receives that type, and the original address has already
created its default pointer type. The replacement address therefore introduces
neither a fresh pointer type nor an identical-type conversion node.

The selected initial stores and calls do not select a replacement-producing
GIMPLE folder: inspected canonicalization in `gimple-fold.cc:6532–6677`,
the handwritten assignment/call dispatch at `:456–570,5959–6090`, and
`gimple-match-exports.cc:736–900`. Component stores with literal/pool addresses
do not select MEM_REF rewriting; ADDR single-RHS assignments and void calls
without an LHS do not enter the generated matcher. This does not cover earlier
GENERIC conversion or any unprojected metadata expression.

Direct call/return warning-copy demand is at most C+1, independently checked
at `gimple.cc:385–431`, `gimplify.cc:1874–1888` and
`warning-control.cc:190–220`. Incoming warning-map population and backing
remain unpriced. These sites do not bound all possible metadata/helper warning
activity, and the fixed pre-gigi event count is not reused for that map.

The parent replayed the frozen 64-case helper checkpoint once in
**3.481395906 seconds**, with zero exit status and empty stderr. Output exactly
matches retained `check-results.json`, SHA-256
`b10a0a464769ab8f10ad688b03f95348dba671fcb727296603301a6f94444b67`.
A separate default callable replay took **2.459534552 seconds**. Its JSON
equals the retained result apart from the explicitly documented `source_path`
attribution to the integration worktree; output SHA-256 is
`4355ce82ccb5f1ed5a1f0f3d5656639d102288d8244738b31b7d398b293e5577`.
The checked GCC/Ada/plugin sources are the retained pinned roots named by the
packet. No native compiler/prover execution was performed.

## Binding correction disposition

The inherited direct interface asserted one outer bind without excluding
call-local retained blocks. The existing [gigi binding transfer](../research/retained-backend-gigi.md#binding-requests-and-retained-bind-nodes)
already permits C+1 binds for this source family. Astra Max's bounded ingress
analysis identified the omitted application; the parent independently checked
`trans.cc:4899–4921,9271–9273`, `utils.cc:735–766`,
`gimplify.cc:427–430,1680` and `gimple-low.cc:701–705,1446–1449`.
The sound conservative correction is:

- Direct allocation events: 10C+2N+2; initial tuples: 4C+2N+2.
- CF block-location calls: 4C+2N+2; post-CF executable/CFG shape unchanged.
- At most C+1 binds with simultaneous depth two. `reserve(8)` at length one
  needs nine slots; the pinned `vec.cc:151–174` doubles eight to sixteen.
  Initial/grown backing requests are 72/136 bytes, cumulatively 208.
- Local VAR_DECL demand stays C because `record_vars_into` skips TYPE_DECLs.
  Bind handling adds no direct warning-copy call, retaining C+1 there.

The parent corrected an intermediate worker calculation of twelve slots/104
bytes by checking the actual small-vector growth branch. That draft was not
integrated. The repaired callable separates bind tuple requests and records
depth, backing count/capacity and cumulative bytes explicitly. This establishes
a sufficient bound without claiming exact retained-sample bind multiplicity or
a new native counterexample. It does not establish whole-body W or close any
remaining frontend/helper/collector lifetime.

After the binding correction and reviewed GPR attachment, all 66 aggregate
checks passed (3.678089316 seconds reported by the command runner), including
the new direct tuple/depth/backing assertions on the seven source variants.
The default result was regenerated in 3.264462293 seconds; whole-pipeline
capacity remains false. No native execution was needed for either check.

The helper author selected Astra Extra High; the named ingress escalation
selected Astra Max. These are selected settings, not runtime confirmations.
The primary reviewer/integrator's live model and effort are not exposed by the
tools; no lead change is claimed. Replay times above were measured around the
subprocesses; a separate total parent-review interval and token/monetary costs
are unavailable. Other integration and review activity overlapped this work.
Historical source pins and review claims remain tied to their original inputs;
the current corrected direct interface supersedes their one-bind/72-byte claim.
