# Independent review of the fixed Why3 prefix composition

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed target: `74b788520a333e225c63e8cd3b0dd8271e94219c`.
Selected reviewer: GPT-6 Astra, Extra High. Runtime confirmation of the model
and effort is unavailable. Measured review interval: 17:56:50–18:01:31 UTC
(281 seconds), excluding report authoring and commit. Token use and cost are
unavailable.

**Accepted within the documented conditional scope; no material finding.**
The [composition](../../research/retained-producer-prefix-composition.md)
supplies the missing source partition and joins the preceding fixed-context,
collection/dimension and semantic-count components. This acceptance concerns
the five exact, independently launched fixed-library processes, from entry to
the first Why3 module through entry to `Gnat_checks.init`, before its body.
It retains the original progressive-proof arguments, pinned driver/configuration,
controlled runtime, fresh session, path-equivalence restrictions and explicit
external behavior/operation contracts. It is an inspected source argument,
not a machine-checked completeness theorem.

Review inputs were the target composition and its packet (`README.md`,
`check.py`, `identity.json`, retained result and archived sources), together
with the fixed-context, prefix-GC and prefix-count arguments and the component
evidence replayed by the checker. Existing successful collection and source
correspondence evidence was reused. The following checks addressed the new
composition obligations:

- `gnat_checks.ml`, `gnat_main.ml`, `driver.ml`, `session_itp.ml` and `task.ml`
  support the endpoint and callback distinction. Driver loading collects
  transformations; their application follows this interval. Initial task
  splitting and SV6 checksum/shape creation are inside it. Server connection,
  goal registration and prover scheduling are outside it.
- The retained `term_size` caller inventory, reduction-engine interface and
  `compute.ml` registration sites support exclusion of normalization and its
  unfolded-size arithmetic. The other caller is in an unloaded plugin.
  This reasoning does not depend on assertion enablement.
- The new dependency-rank, quantifier-projection, region-height,
  application-spine, tuple-loop and array-midpoint joins match their archived
  source. In particular, dependency rank takes a maximum with memoization;
  region height follows one unary path; recursive quantifier projection
  charges fresh construction. None substitutes physical DAG size for an
  unfolded occurrence total.
- Container/string utilities and numeric/syntax formatting support the stated
  structural bounds and checked-conversion partition. SV6 selects `const_v2`,
  avoiding the exponent-padding route. The decimal decoder identified in
  `termcode.ml` is commented out; version autodetection is unselected.
- The inference hooks require absent attributes or flags. `Debug.stats` is
  enabled, but the outer initialization timer updates only after the endpoint;
  the reviewed remaining timing callers belong to later operations.

The simultaneous first-event argument keeps the allocation/control-flow
transfer conditional on the fixed context and runtime/cache premises. The
separate guarded occurrence argument is essential: the physical bound
`B = 88,828,616` does not bound shared-term expansion. The semantic component
covers 146,259 guarded operations, with maximum 47. This separation, together
with the source partition, supports composition without treating a successful
example as an admission test for arbitrary source.

Independent validation ran the packet's offline checker with
`--output /tmp/silver-fixed-why-prefix-review-20261018.json`. All four component
checker entry points passed; the resulting JSON exactly equals the retained
`result.json`. This checks the five input identities, eleven-file import join,
retained source identities and combined inequalities. The packet's native
evidence is Linux x86_64. No new native producer, debugger, solver, Lean build
or broad suite was run. The broad source scan and numeric replay are review
aids, not proofs of reachability or source semantics.

Acceptance does not transfer to a later `per_check` configuration, a changed
driver overlay, production launch adoption or any stage after the endpoint.
Later transformations, solver/result/report/session handling, producer/native
phases, variable Main, whole-pipeline capacity and complete automatic discharge
remain outside this result. The historical incomplete component flags remain
accurate for their individual packets; only the documented conjunction closes
this selected prefix.
