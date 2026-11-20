# Reduced #373: regression checkpoint, 2026-11-20

**Regression coverage is complete through 282 fresh and 475 reviewed retained
passes, covering all 757 current unique unittest IDs.** This packet does not yet
record final native compiler or complete Lean/source/module/axiom assurance, nor
the fresh canonical focused compiler probe. Those remain separate outstanding
checks. No cold rebuild or independent kernel replay is claimed.

The reviewed implementation is `f0a773fbcb9eea9574b037812e888029b7f970cb`; its
scripts/tests were frozen for the fresh run. Record head `cd17bc1fdf` adds review
and applicability documentation. The [independent review](../../reviews/review-proof-efficiency-373-20261120.md)
accepted the repaired implementation and the 475 retained passes' applicability.
The review requires a fresh native build and final assurance evidence separately.
No compiler, library, Lean source, catalogue, sample or language change is supplied
by this tooling package.

## Fresh affected regression run

Managed run `20261120T152415-e5e1f5ee6934`, task `#384-tooling-regressions`,
passed on native **Linux x86-64**, machine `silver`. The child was ordinary
`python3 -m unittest discover -s tests -v` with nine repeatable `-k` module
filters. [Managed status](managed-status.json), compressed [native output](native.log.gz),
[events](events.jsonl.gz), [wrapper output](wrapper.log.gz) and
[wrapper timing](wrapper-timing.json) retain the exact command, inputs and result.
The test phase and wrapper exited zero, with no skips. The managed context
manager's successful final event has its normal null `returncode`; the explicit
test-phase event records zero.

| Module | Fresh passing IDs |
| --- | ---: |
| `test_evidence` | 79 |
| `test_lean_evidence` | 52 |
| `test_dev_runs` | 40 |
| `test_run_history` | 35 |
| `test_proof_provenance` | 27 |
| `test_lean_source` | 17 |
| `test_platforms` | 16 |
| `test_lean_run_history` | 13 |
| `test_lean_modules` | 3 |
| **Total** | **282** |

Unittest reported **1,193.641 seconds**; managed elapsed was
**1,196.1427644 seconds**, from 15:24:16.448161 to 15:44:12.591170 UTC. The
outer wrapper measured **1,197.2787005310092 seconds**, 728.304663 child user
seconds and 559.941533 child system seconds. Its maximum child RSS observation
was 1,618,168 KiB; this `RUSAGE_CHILDREN` value is not a simultaneous process-tree
peak or a host memory measurement. These scopes differ and establish no speedup.
The wrapper captured an invoking stack soft limit of **16,384 KiB**, hard limit
unlimited. This is a recorded setting for the actual fresh run.

The host exposed 22 CPUs. At launch, two workers were requested/granted and nine
were automatically available after existing reservations. The smaller reservation
was deliberate for this serial unittest driver and its fixture workload; this
nonproof test command reports the reduction without a mandatory resource reason.
Reservations are not OS thread caps. The suite includes actual small Lean/Lake
fixture builds using the newly bootstrapped pinned tool; native compiler/solver
and foreign-platform routing fixtures use mocks where their tests specify them.
It is not a fresh complete Silver compiler proof, whole-project Lean audit or
native macOS validation.

## Exact census and retained applicability

[Regression accounting](regression-accounting.json) records every current ID,
its fresh or retained run, all 724 IDs observed in the retained raw log, the
33 added IDs, per-module source hashes and 70 captured scripts/tests input hashes.
All captured scripts/tests hashes still match the reviewed run's inputs. Discovery
used `sys.path.insert(0, str(Path.cwd()))` before `unittest.discover('tests')`;
this evidence extraction did not execute tests again.

The existing [724-pass raw log](../bounded-string-building-400-20261118/external-20261120/native.log.gz)
is from `20261120T130632-15ab84282224`, reviewed head
`9cf913a3a4a69cb40fe99ea39f21d0e237647fe1`. Its uncompressed SHA-256 remains
`1893d4362f30dc6e97ef346f66970b9a330a609f1dd7d5afb09ffedeb45f991b`.
Of those IDs, 249 were freshly rerun in the affected modules and 475 supply the
reviewed retained coverage. The 33 new IDs also passed fresh: **282 + 475 = 757**,
with no missing, extra or duplicate exact ID. Every retained test module's source
bytes match the prior reviewed revision; broader applicability is the independent
review's explicit judgment, not a consequence of a test name or file hash alone.

The corrected census matches unittest header IDs without requiring an ellipsis
on that same line or a line-start anchor. Four historical tests have a
`shortDescription` between their header and `... ok`; requiring same-line ellipses
counted only 720. The four recovered IDs are recorded explicitly in the JSON.
The nine historical `tests.test_shared_bindings.*` IDs and their corresponding
bare `test_shared_bindings.*` IDs are distinct actual discovery entries. Both
forms are preserved; stripping the `tests.` prefix would falsely collapse nine
historical tests. No IDs are inferred to fill a desired total, and no rerun was
needed to repair this bookkeeping parser.

## Lean fixture tool and archive identities

[Lean tool identities](lean-tool-identities.json) records the actual installed
`lean`, `lake`, `leanchecker` and shared-library hashes, bootstrap script hash,
`proof/lean-toolchain` pin and authenticated distribution digest. The
[bootstrap stdout](bootstrap-lean.log) reports Lean **4.34.1**, commit
`5045d0056413266e57c625dcd7c365b10e377c52`, native x86-64. The local archive
matches the bootstrap's pinned upstream SHA-256
`3013aba02bb8bf31b1cf8c9d956d60fb95bb1c10920dfe91abcaa59cb461ddac` and installed
marker. The log does not independently identify whether that archive was
downloaded or copied into the host tool directory beforehand. Installed paths
are the integration worktree's native `.tools/linux-x86_64/` paths.

[Archive manifest](archive-manifest.json) records compressed and original hashes
and byte counts for each retained raw record. Compression uses deterministic
mtime zero. This packet is evidence collection only: it neither replaces native
or Lean assurance nor changes the approved deferrals of #381/#382. No Worca run,
GitHub write, test rerun, commit or CLI memory update was performed in assembling
it. Selected evidence collector: GPT-6.1 Sol / High; independent runtime model,
effort, token and cost confirmation unavailable.
