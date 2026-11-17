# Two-worker complete checkpoint — retained interruption

Run `20261116T233051-b2fd2290a41d` used frozen implementation
`d60bd8a899fcc66e5ef40112423b7f94b2e4becc`, the accepted Domain focused success,
and all 998 retained primary objects. [preflight.json](preflight.json) verifies
all 1,116 captured repository inputs against that commit, unchanged proof bytes
since the focused gate, and all 32 unchanged authoritative embedded sources.
Only `check_evidence.py` and `silver_library_reports.adb` changed among the
captured inputs since the focused success. The managed summary had no active
reservation; the native complete audit and build had succeeded and released
their original terminals. The full suite waited for the Lean result.

The exact [command](run-complete.py) was a complete cached check with
`--workers 2 --memory-mb 8192 --provenance --task '#391'`, automatic **12 threads
per Lean process**, no clean build and no replay. Two workers were selected
after the prior actual 12-worker aggregate RSS guard and a 2.634 GiB focused
two-worker peak; the remaining dense whole-project overlap was unmeasured.

This attempt was **interrupted by the agreed aggregate RSS guard**, with no
Lean proof, linter or source-correspondence diagnostic. At 88.186 seconds the
tree RSS reached **10.088638 GiB** while host `MemAvailable` was **6.698944 GiB**.
At that sample, one Lean process used about 7.136 GiB RSS, another 1.697 GiB,
Lake 1.164 GiB and the Python runner 0.092 GiB. The most recent setup files were
`ComposeContractSourceCandidate` and `ComposeDeclarationSourceCandidate`.
This identifies the overlapping candidate setup, not an exact PID-to-module
mapping, which was not yet sampled in this attempt.

The 10 GiB tree/1.5 GiB host monitoring limits remained unchanged. They are not
hard OS caps, and RSS can count shared pages multiple times. The supervisor
sent SIGINT only after the actual guard fired. Original tool session **70474**
collected runner exit **-2** and launcher exit **130**, after 88.239 seconds;
build-phase elapsed time was 83.677 seconds. The full axiom/module audit did
not start. The worker reservation was released.

Two cheap build jobs completed. All **998** pre-run primary objects remained
present and byte-identical; no new cache loss occurred. The candidate objects
still missing were already absent before this attempt. The exact terminal,
managed events, log, two-second samples, object checks and guard breakdown are
retained here, especially [inspection-summary.json](inspection-summary.json).
No source was changed and no object was restored by guessing applicability.

The lead authorized a **one-worker continuation** from these measured dense
overlap facts, retaining automatic 12 threads, 8192 MiB periodic per-process
threshold and both guards. The continuation adds own-process argument/module
attribution to the samples and preserves this interruption as interruption.
The inherited monitoring model/effort and runtime identity remain unavailable;
native phase/launcher times are retained, while whole-subthread time/token/cost
measurements are unavailable. No repeated focused success, cold rebuild or
independent replay was selected.
