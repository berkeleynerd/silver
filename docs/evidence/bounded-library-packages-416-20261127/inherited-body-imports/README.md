# Inherited original body helpers for packages — 2026-11-27

Run `20261127T222010-a69add04ac5d` passed 76,549 audited declarations across 502
imported modules. All 1629 captured inputs match the checking worktree;
every existing primary input matches. Only the new InheritedBodyImports module
was absent before integration.

The adapter consumes the existing raw source helper definitions and native
contracts below the standalone outer scanner. It derives Basic_Body, scalar and
Boolean targets, Body_Token, Read_Condition and Join_Into meanings over their
full native domains, retaining the exact Native.Context witness and rejected
scans. Its FlowLibraries instance uses the same interpreted body/initial-flow
wrappers. No completed standalone Main parse or empty declaration frame is
required. Package call/recursive interpretation must still establish the actual
call-site domains and wire these inherited operations into the original readers.

The first focus passed. Many inherited dependency objects were missing in this
worktree and were built productively; the build took 198.57 seconds,
then the fresh audit 4.018 seconds. No source cache was copied.
Linux x86_64, Lean 4.34.1, two workers and two threads, 8192 MiB per process,
actual CPUs0–1 within the eight-CPU host allocation. This is focused incremental
validation, not clean, kernel replay or complete feature assurance. Selected
proof role Astra Max; runtime settings are not independently exposed.
