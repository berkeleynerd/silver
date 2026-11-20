# Response to the scoped PR #403 review — 2026-11-20

The [external report](review-9cf913a3a4.md) covers
`9cf913a3a4a69cb40fe99ea39f21d0e237647fe1`. It found no blocker or medium, one low
record defect and six informational observations. The owner then instructed
“Merge it”; PR #403 merged that exact head as `66659c70aaf35e23f08dd6531617ca39c6189a55`.
No Worca approval was supplied by an agent. This response records the delivery
disposition and does not rewrite the external report.

## Current regression coverage and the owner's judgment item

Accept the historical ARM invoking-stack recording defect. That setting remains
unknown. The external review subsequently supplied a fresh complete Linux x86-64
suite on the final head: **724 IDs passed without skips at a recorded, enforced
16,384 KiB invoking stack**. The
[independent applicability review](../evidence/bounded-string-building-400-20261118/external-20261120/suite-applicability.md)
verified all 1,348 inputs and the complete test inventory. This is now the final
regression checkpoint under the ordinary full-suite provision. The delivery no
longer depends on reusing the ARM regression results, so neither a recording-rule
waiver nor another ARM run is needed. The owner authorized merge on that basis;
no historical setting is retroactively established.

The retained complete ARM native/Lean assurance stays separate and applicable to
unchanged governed inputs. Neither the fresh tests nor this response replaces
the required complete compiler proof or source-correspondence evidence.

## Item dispositions

The item numbers below follow the low and observation lists in the report.
Severity is retained. Informational items create no ticket. The accepted low
record item is deferred in [#405](https://github.com/berkeleynerd/silver/issues/405)
under the owner's grouped-backlog policy; issue/board writes were
deferred until after merge as instructed.

| Item | Severity | Disposition |
| --- | --- | --- |
| L1: historical ARM stack setting | Low | Retain the missing-setting disclosure and track the record defect in the grouped backlog. Current coverage is the fresh complete x86 suite above. Future run-setting capture belongs with the existing workflow work; no reconstruction or rerun is proposed. |
| I1: append control changes two things | Info | Noted. Both the loop-local Len indexing and the post-loop Len update independently reject. The documented loop-refinement rule is correct, but the historical control alone does not isolate it. External one-feature twins establish both causes. |
| I2: prepend sample does not discriminate shift direction | Info | Noted. Its particular ranges do not overlap. Two separate regression fixtures detect a forward-shift error, confirmed by external mutation probes. No coverage repair is required. |
| I3: shifted citations and old-state passages | Info | Retain explicitly pinned historical citations and historical handoffs as such. Prefer stable section links for new records and correct ambiguous current citations when next editing those passages. |
| I4: planning candidate sources unavailable in Git | Info | Preserve the disclosed record-only scope of the eight further assessments. They add no delivered sample or supported mapping. Do not reconstruct sources and label them original evidence. |
| I5: four closing-manifest files predate acceptance edits | Info | Noted as disclosed. The manifest binds the pre-acceptance snapshot; later status/link/hash changes affected no governed validation input. Do not claim its hashes match later record commits. |
| I6: recovery archives stay local | Info | Retain transfer hashes, collector/receiver inventories and independent checked results. The external review did not repeat those archive checks. The 645 MB cache remains outside Git; no stronger reproduction claim is made. |

No item requires a compiler, proof or test change for this delivery. The report's
scope limits remain. Broad string-building stays open under #395, #373 remains
separate, and PR #385 remains held. This record authorizes no follow-up repair or
successor feature.
