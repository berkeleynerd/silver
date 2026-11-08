# Isolated fixture diagnostics — 2026-11-08

These observations investigate the repeated initial-build timeout in the
[regression packet](../final-regression/README.md). Neither is a passing
regression fixture. The original full run and focused follow-up remain failed;
their audit and object-reuse/edit stages still require a complete pass.

| Managed run | Observation | Result |
| --- | --- | --- |
| `20261108T054614-dc5613468a66` | Cold configuration only, exact Lake prefix, then immediate marker | Passed in 22.878 seconds; no module build |
| `20261108T055144-283b5d488a27` | Cold initial build with original targets and 60-second deadline | Timed out during Cursor, after Lexical, CertificateWitness and Admission compiled |

Both used the original one-thread/one-worker and 2,048 MiB settings and matched
all 19 retained prepared source/configuration hashes. Each ran in its own
workspace through the managed runner with one reserved worker. The current
environment was captured explicitly; the historical ambient environment and
scheduling state are unknown. No source, test, harness or timeout was changed.

Each run directory has a compressed evidence bundle and an index with its
SHA-256, size and member count. The bundles retain observers, frozen inputs,
captured streams, 250 ms process/CPU/I/O/wait samples, host observations,
configuration artifact times and managed events. The initial-build bundle also
retains completed module object families and the partial workspace. Private
complete environment snapshots are excluded; the shareable records contain
selected relevant values and hashes of other values.

The [resource and diagnostic review](../../../reviews/review-scalar-functions-delivery-20261108.md)
records the exact phase interpretation and limits. The configuration trace is
written before elaboration, so its presence is not a completion marker. Current
configuration and serial module costs are measured; historical contention and
a complete root cause are not established. The initial-build timeout cleanup
verified and killed only its newly created diagnostic session processes, then
reaped them. No external proof process was signalled.

A separately authorized single-module profiler observation is pending. Any
further fixture run must follow the resulting diagnosis and retain the existing
required checks and deadline.
