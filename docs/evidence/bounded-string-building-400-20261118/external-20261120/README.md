# Final external regression checkpoint — 2026-11-20

The external reviewer ran the complete managed suite on PR #403 head
`9cf913a3a4a69cb40fe99ea39f21d0e237647fe1`, tree
`9079ea5a6a2628b8093110733e5097366b0e1cf1`: **724 tests passed, zero skips**.
The owner then directly instructed “Merge it” in the Codex conversation.
PR #403 merged at 14:46:28 UTC as
`66659c70aaf35e23f08dd6531617ca39c6189a55`. Its tree equals the reviewed tree.

The [independent applicability assessment](suite-applicability.md) rechecked
all 1,348 captured inputs: 1,340 repository files match the exact Git blobs and
eight support files match the reviewer-built compiler, generated Ada, toolchain
contexts and Python. It also matched all 724 test identities. This **fresh
complete Linux x86-64 suite is the final regression checkpoint**, replacing the
earlier ARM-plus-two-test composition as the delivery's coverage basis.

| Record | Value |
| --- | --- |
| Worca review | `b793349a` |
| External job | `20261120T130632-078198218-exec-07856a` |
| Managed test run | `20261120T130632-15ab84282224` |
| Command | `python3 scripts/dev.py test` |
| Host / reservation | Linux x86-64 `silver`; 22 CPUs / 22 managed workers |
| Invoking stack | 16,384 KiB, recorded and enforced by the external runner |
| Start / finish | 13:06:32.658938–13:45:23.375938 UTC |
| Unittest / managed / wrapper seconds | 2,329.820 / 2,330.666837034 / 2,330.956 |
| Result | Phase and wrapper exit 0; managed outcome success; no timeout/watchdog |

The managed final-event return code remains its normal null context-manager
default. Tests that deliberately reduce their child stack retain those limits.
`native.log.gz` and `events.jsonl.gz` preserve the raw managed records. The
suite ledger, external job result, review manifest and execution summary are
also retained here. `SHA256SUMS` covers this packet except itself.

The [external report](../../../reviews/review-9cf913a3a4.md) is preserved unchanged.
It reports no blocker or medium, one low historical ARM stack-record gap and six
informational observations. This was a scoped light review of the changed
samples/tests/Rosetta/docs, not a new comprehensive compiler/proof review.
The [response](../../../reviews/review-9cf913a3a4-response.md) dispositions every
item and distinguishes current coverage from the historical recording defect.
No missing ARM setting was invented, no recording requirement was waived, and
no ARM rerun is needed for this current complete Linux result.

Native and Lean assurance remain the independently accepted retained ARM
checkpoints: 19,726 native checks and 1,035 Lean modules / 166,332 declarations.
The new test run is not a new complete compiler proof, Lean import audit or
kernel replay. The [recovery packet](../delivery-20261120/README.md) retains
their applicability checks and platform limits.

The four review lanes and challenger used Claude Fable 5.2 at Max; the report
writer used High. Their runtime process arguments and execution records
confirmed those selections. The workflow ran from 13:06:09.522 to report
completion at 14:28:48.692 UTC (82 min 39.170 s). Its reported $83.2126 is a
harness estimate; its aggregate active time sums concurrent steps and is not
wall time. Token totals were unavailable. Owner authorization to merge spans
45 h 31 min 35 s, including waiting, recovery, review and transfer; active
development time is not known.

The report waited at its owner-only posting card. The owner's subsequent direct
merge instruction was carried out without an agent approving that card. The
already-completed workflow was stopped at the obsolete posting hold, preserving
all results. This record retains the report in Git; no claim of a Worca gate
approval or a separately posted external-review comment is made.
