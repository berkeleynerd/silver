# Final-input symlink-TMPDIR fixture — 2026-11-08

Managed run `20261108T064731-9f1ab6dc731c` failed with one test, one error and
zero skips. Its unchanged nested `PlatformIsolationTests` invocation exceeded
the existing 180-second outer subprocess deadline. Unittest elapsed was
180.644 seconds; actual managed completion was 06:50:40 UTC after 187.347
seconds, and the owning tool returned exit 1. This is not a passing fixture or
an established cause of the earlier full-suite timeout.

The exact command was:

```sh
python3 -B scripts/dev.py test --jobs 2 --task '#298 final regression' \
  --reason 'One unchanged symlink-TMPDIR fixture after retained637-method failure, exact1100-governed-file match and82-proof-file synchronization to47fe4003c0; original180s outer and60s worker deadlines/assertions preserved, native12 plus serialLean1 remain separate.' \
  -- -p test_platforms.py -k test_symlinked_tmpdir_preserves_platform_setup_and_routing
```

The isolated regression checkout received only the reviewed 82 proof-file
changes in local sync commit `b40999754c`. This sync-only commit must not be
reapplied to the integration branch, which already contains the changes at
governed target `47fe4003c0`. All 1,100 tracked governed files, including all
821 Lean source files, matched that committed target by Git blob identity and
retained SHA-256/size inventories. Postflight repeated every file comparison
and the complete Lean file-set comparison with no differences. Native source,
scripts, tests, samples, catalogue and project configuration were unchanged.

The actual host is Linux x86_64. Fresh managed status showed native validation
using 12 workers and serial source validation using one; this run reserved two
workers in its separate checkout. Those reservations do not impose an OS
process limit. The original nested suite still used its normal mocked external
tools, real generators, four-host concurrency cases, 60-second worker limits,
symlinked temporary paths and every original assertion. No harness, environment,
deadline or acceptance condition was changed. No signal was sent by the
coordinator, and a post-exit process inspection found no remaining fixture
processes. The exception traceback does not include the nested suite's partial
captured streams, so this packet does not infer how many nested cases completed.

The [index](index.json) retains the managed metadata/events/log and pre/post
input inventories. All five compressed artifacts were independently decompressed
and checked against their recorded sizes and SHA-256 identities. The original
637-method suite and this focused follow-up remain failed. Further diagnosis
must preserve these outcomes; no automatic retry or deadline adjustment follows.
Coordinator runtime model/effort telemetry and token/cost measurements are
unavailable. An attempted routine subthread assignment was refused by the
session thread limit, so the coordinator performed this exact synchronization
and unchanged test directly; no additional agent ran it.
