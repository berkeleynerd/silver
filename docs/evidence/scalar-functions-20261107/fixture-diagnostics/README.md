# Isolated fixture diagnostics — 2026-11-08

These observations investigate the repeated initial-build timeout in the
[regression packet](../final-regression/README.md). None is a passing
regression fixture. The original full run and focused follow-up remain failed;
their audit and object-reuse/edit stages still require a complete pass.

| Managed run | Observation | Result |
| --- | --- | --- |
| `20261108T054614-dc5613468a66` | Cold configuration only, exact Lake prefix, then immediate marker | Passed in 22.878 seconds; no module build |
| `20261108T055144-283b5d488a27` | Cold initial build with original targets and 60-second deadline | Timed out during Cursor, after Lexical, CertificateWitness and Admission compiled |
| `20261108T060219-fd618279bf6d` | One direct CertificateWitness compile with pinned profiler options | Passed in 9.604 seconds; exclusive import cost 6.870 seconds |
| `20261108T061828-f176c7d39979` | Fresh authenticated Lean installation on container-local overlay | Passed; all 18,381 distribution entries and 15,127 baseline library identities matched |
| `20261108T062237-55f39cc9f940` | One matched CertificateWitness profile using that local installation | Passed in 4.836 seconds; exclusive import cost 2.910 seconds |
| `20261108T064023-1bc9e7d6f89f` | Full unchanged original fixture in a separate test root using authenticated local tools | Failed at the unchanged 60-second initial-build deadline; no audit/edit subtest reached |

The first two used the original one-thread/one-worker and 2,048 MiB settings and matched
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

The profiler observation recorded 3.17 user and 5.17 system CPU seconds;
elaboration took 46.9 ms. The installed library's 15,127 files were unchanged
before and after the run. Hashing warmed caches, and the earlier successful
fixture's imported-library identity is unknown. The current installation is
on a measured `virtiofs` mount. The separately authorized local installation
and matched profiler comparison both completed. Their
[combined bundle and exhaustive member inventory](local-installation-20261108/index.json)
retain unchanged bootstrap inputs, complete distribution comparisons, profiler
inputs and loaded-file identities, process observations and both managed ledgers.
Every bundle member's bytes and SHA-256 were independently read and indexed
during integration; both ledgers record actual successful completion.

The local profile used identical source, setup and normalized arguments and
environment. Source/output stayed on virtiofs; installed tools and libraries
were on the verified overlay filesystem. All 4,966 sampled mapped-file identities
matched after installation-prefix normalization, and no old installation file
was loaded. Sampled system CPU decreased from 5.17 to 1.90 seconds. Both runs
warmed caches through identity checks; extraction and scheduling were not
controlled, and serialization time increased. The original fixture used /tmp
for its source/output workspace. These limits prevent treating this one
observation as a complete causal explanation or a passing fixture. Existing
installations and prior evidence remain untouched. The next fixture check must
retain its original assertions, deadline and complete edit/audit sequence.

The authorized original-fixture attempt then failed despite those local tools.
Its [bundle and exhaustive inventory](20261108T064023-1bc9e7d6f89f/index.json)
retain exact copied inputs, normal ROOT/import checks, complete distribution
identity, exception streams, the pre-cleanup workspace, process observations
and managed records. All 53 bundle members were independently read and indexed
by size and SHA-256 during integration. Postflight rehashed all 17,792 captured
input files with no difference. The explicitly scoped TMPDIR used the same
overlay filesystem class as the original unset-TMPDIR fixture.

Unittest recorded one error and zero skips after 64.277 seconds. Actual captured
output shows five completed modules; SourceLexer was still running at the
snapshot and no line-chunk compilation had started. The observer subsequently
reaped that completed child without a signal; its later exit does not complete
the killed Lake build or unexecuted test stages. The failed managed run finished
in 113.471 seconds, including setup and retention. All owned descendants exited.
Local storage alone was insufficient. Read-only assessment of the test
watchdog's purpose and measured cost is the next step; no further run or fixture
change follows automatically from this failure.
