# Interrupted complete native run recovery

Issue #291, native Linux, 2026-10-30. Run `20261030T142912-eb0b24fc2191`
has no `finished` event. After the owner interrupted the lead turn, its lease
was released and all native processes were absent. The existing managed status
interface reports it as interrupted; its exact end time, duration and exit code
are unknown. Its original journal and log remain unchanged. No complete native
proof success is claimed.

Before restarting, all 143 checkpoint source/script/project hashes were
rechecked, and 2,467 partial object, report and session files (1,886,782,238 bytes)
were copied and byte-verified under the original run's local
`supplemental-recovery/` directory. That includes 75 unit reports and 206 Why3
sessions; the complete output-profile unit report is absent. The compact
`recovery.json` records available parser-session goal markers, which are partial
work and do not replace the required complete report audit. The populated
965 MiB compiler proof cache remains at its existing path; it was neither
merged nor tuned during recovery.

A diagnostic was recorded through `dev.py runs diagnose`, preserving the
interrupted state without inventing a terminal event. Replacement run
`20261030T185133-160271e45fa1` uses the existing full strict managed route, the
same cache and exactly the same 2,561 preflight hashes. The only command change
is four reserved workers in place of two, supported by measured host headroom.
The final complete audit, provenance check and two-file restoration remain
obligations of the replacement run.

Selected native subthread: GPT-6 Astra / Extra High. Live runtime model
confirmation and token/cost measurements are unavailable. Recovery preserved
computed work and restored an active audit without changing native source or
proof policy.
