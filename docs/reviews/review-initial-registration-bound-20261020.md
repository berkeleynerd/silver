# Independent review: initial registration bound

2026-10-20, research #119 / #155. Exact target:
`66ba7f63647e72f0b1e683c39f4017803fc78149`, specifically
[the initial-registration argument](../research/retained-why-initial-registration-bound.md)
and its matching evidence packet. At review handoff the integration checkout
had advanced to `595f49ed1bf61921547d22004c5de10baa1d501a`; the reviewed note and
packet had no difference from the exact target.

**No unresolved objection within the documented controlled-prefix
source/runtime/debugger relation.** This accepts the new debugger-policy remedy
and initial-domain derivation only. It does not establish later no-wrap,
uncontrolled production-prefix behavior, or complete writer/save capacity.

## Independence and inputs

Reviewer agent: `/root/save_path_initial_state_round32_20261020`.
Selected model/effort: **GPT-6 Astra / Extra High**. Runtime confirmation,
token usage and monetary cost were unavailable.

This reviewer previously authored the separate tuple-preparation bound at
`f29fe06a2228e9fe518c2b1f85e979f86e34bb90` and supplied related arity-source
findings. That contribution is distinct from the root-owned registration-count
and debugger-stop remedy reviewed here. This reviewer neither authored nor
suggested that remedy; the combined reviewer who suggested it was not used as
its independent acceptance source.

Inspected inputs were:

- The target research note and complete
  `docs/evidence/retained-why-initial-registration-bound-20261020/` packet:
  checker, input/result/round records, source witnesses, native bodies and
  provenance, and retained target-free debugger-default query.
- The retained capture-common archive's registration and inline launchers and
  probes, including `Phase`, `InlineEntry`, `finish_capture`, guard handling,
  event hooks, and observer-helper control sites. The fixed scripts have no
  signal-policy override or signal-stop continuation hook.
- All five retained identifier-counter records and summary snapshots, with
  their process-local closure/counter pointers and actual endpoint phases.
- The reused initial-state/callback-preservation notes, registration replay
  record, and the exact private type-symbol constructor and tuple-registry
  source. Existing source/native and runtime ownership premises were retained;
  hashes alone were not treated as semantic assurance.

## Findings

The actual launchers use the pinned debugger with `-nx -q -batch`; each fixed
script issues one `continue` after `starti`. The retained query establishes
default Stop=Yes for SIGINT, SIGSEGV and SIGBUS. Under ordinary debugger
stop/delivery semantics, these signals cannot reach their application or
stack-fault recovery paths and then reach the successful cuts without another
continuation. The observed cuts and fixed control scripts therefore close the
identified registration-abandonment routes for these controlled prefixes.

The inspected native `id_register` increments once and charges 40 minor-heap
bytes. Its only allocation-undo/exception route is the inspected slow allocator
path. The remaining pending clients are closed by the accepted single-worker,
finalizer and Memprof premises; no protected minor-heap reset is credited.
Completed charges give `5*N <= B < 2^28`, excluding the first `2^62` signed
counter crossing before interpreting the captured nonnegative `I` as `N`.

`Ty.tysymbol` has a private immutable representation and its sole record
constructor registers an identifier. `ts_tuple_ids` starts empty and each
addition by its sole writer follows a new type-symbol registration. Thus both
initial domains are bounded by `I`, including negative tuple-arity values.
The consequence is a cardinality bound, not a maximum-arity claim.

## Review record

The completed review ran **13:11:03–13:13:55 UTC (172 seconds)**. It was
read-only: no checker rerun, debugger query, native target/capture/proof
execution, or GitHub write. This report retains that completed review without
repeating it. Its commit is review bookkeeping, separate from the reviewed
implementation target and from any later composition or follow-up work.
