# Eight-CPU limit review — 2026-11-21

Owner-authorized scope: constrain all current and future Silver work to the
host's eight-CPU allocation while preserving active computation. The reviewed
runner changes are `063de76687` and `d41c4468ef`; the accompanying driver changes
bound application proof/build and native regression helper builds at one worker.

Independent reviewer selected: GPT-6.2 Astra, Max. Runtime settings were not
independently exposed. The reviewer read code and pinned vendor documentation;
it ran no builds, proofs or tests. The implementing runner subthread selected
GPT-6.1 Sol Extra High; guidance used GPT-6.1 Sol High.

Two findings were repaired before this record: selecting the first allowed CPUs
for every run discarded the throughput reserved by concurrent grants, and two
native Lean test fixtures still inherited hardware-default worker counts. The
runner now prefers unclaimed allowed CPUs within its existing reservations and
inherited mask; the fixtures bound both Lake workers and Lean threads. Review
found no remaining material defect in that bounded scope. The managed fingerprint
includes the resolved thread count and worker grant.

The pinned GNATprove `configuration.adb` at revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0` uses the machine CPU count for `-j0`;
`gnatprove.adb` forwards it to GPRbuild and Why3server. Positive `-j1` is the direct
remedy for a one-CPU application-compile share. It serializes application proofs
on every platform and can change solver ordering and elapsed time. All solver
choices, step/memory limits, timeout, report rules and discharge requirements
remain unchanged. No Ada contract, Lean theorem, checked source certificate or
shape pin needs editing for these command literals. The checked-in development
runner ceiling is eight on every host; smaller native counts or affinity still win.

[Host observations and focused test runs](../evidence/host-eight-cpu-allocation-20261121.json)
record the live cpuset, inherited affinity and retained launch-flag exceptions.
The final focused runner batch passed 155 tests, including two real native Lean
configuration fixtures. This is not final compiler assurance: after the requested
pause, rebuild the driver, rerun affected application regressions including the
64-leaf proof-policy case, and finish #410's complete native and Lean audits on
final inputs. Normal cache reuse remains available. The current long runs cover
their original frozen inputs, with the live resource adjustment recorded separately.
The post-reboot eight-CPU detection check was pending at this original review checkpoint.

Follow-up after restart, 2026-11-21: the linked host evidence now records eight
detected CPUs and affinity/effective cpuset 0–7. The rebuilt driver and corrected
complete native audit passed; the serial maximal-expression regression and
complete Lean/source checkpoint remain pending. This follow-up records subsequent
validation and does not extend the original review's scope.

Lead continuation at 21:55 UTC: the complete Lean/source checkpoint also
passed on the final inputs. The host evidence now includes a scan of 140 live
threads across the concurrent Lean and regression process trees: every thread
stayed within its assigned guest CPU set, with no exception. The maximal-case
regression remains active; its result is recorded separately in the capability
packet. This is subsequent validation, not an expansion of the original review.
