# R82: required report consumer interface

2026-10-24 UTC, #119/#194. Author `10604f4d21` and independent review
`02a49ade46` are accepted and integrated. **#194 is technically complete at
its conditional interface scope and In review pending delivery.**

The [derivation](../../research/retained-required-report-consumers.md) covers
the complete required report set, both GNATprove parsing passes, persistent
symbols and database counters, summary arithmetic, populated SARIF/VSS storage
and streaming output, and Silver's projection/complete audits. SARIF remains
mandatory on the selected success path. Per-file catch-and-continue behavior
cannot establish proof coverage; all five output-program reports are required.
Current fixed buffers and future scalable #89 obligations remain distinct.

The [review](../../reviews/review-required-report-consumers-20261024.md)
accepted three repairs: #203 separates Text_IO characters from encoded file
bytes, including the parent's summary delta; #204 charges three no-check stderr
lines; #205 exposes the common-path provider and its dominance checks. The
controlled SARIF alias-stage explanation was clarified without changing its
512+16*growth allowance. No concrete native overflow was demonstrated.

The reviewer ran one focused audit at the final freeze: 76 complete source
files, 23 current Silver snapshots and eight pinned providers. Checker time was
0.401562 seconds; invocation time was 0.573198 seconds. The recorded review
interval was 867.593959 seconds, including source inspection, coordination,
repairs, audit and report writing. [Integration](integration-result.json)
reconciled 14 frozen files, those eight providers, 23 current source snapshots
and 94 unchanged native pins in 0.130580 seconds. Author and reviewer results
match except elapsed time. No component/predecessor/native/compiler/prover/Lean
replay occurred during integration.

Both author and reviewer selected GPT-6 Astra / Extra High. Runtime confirmation
and isolated token/cost measurements are unavailable. The lead setting cannot
be confirmed through this interface. Three explicit gaps were repaired before
the single audit, avoiding repeated successful reviews. This is an observation
of the workflow, not a causal model comparison.

Remaining parent duties include actual path/UTF-8/configuration/source-behavior
and parent Text_IO state joins, reported-time representation, and actual
fixed-source applications. The equations and orientation examples do not
establish those concrete fits. The reported-time input must be justified from
source/configuration; observed duration cannot decide membership. That provider
is tracked in [#206](https://github.com/berkeleynerd/silver/issues/206). #201 and
#202 continue the general-native and ordinary-Main Why derivations. Complete
checked composition/correspondence, usefulness comparison and final independent
review remain necessary for #119. No new percentage or ETA is established.

Oracle, tools/pins, current admission, physical-resource premises and one
process-wide e<=2/two-callback/three-save allowance are unchanged. Production
#88–#94 stays unstarted; PR #121 remains draft/unmerged, with merge unauthorized.
The harness still displays paused while owner-authorized project work continues.
Original author and reviewer branches are published with this integration so
exact Git evidence remains fetchable. CLI memory is unavailable.
