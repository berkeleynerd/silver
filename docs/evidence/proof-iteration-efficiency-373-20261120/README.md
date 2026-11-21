# Reduced #373: final validation, 2026-11-20

**Original checkpoint, 2026-11-20: complete native and Lean assurance passed,
with all 757 unittest IDs at that target covered by 282 fresh and 475 independently
reviewed retained passes.** Both [real focused compiler commands](focused-native/README.md)
also passed. The [internal closing evidence review](../../reviews/review-proof-efficiency-373-delivery-20261120.md)
accepted that checkpoint and retained-test applicability; its findings were resolved.

This census and the archived runs below describe reviewed implementation
`f0a773fbcb` and delivery target `8dc409b303`, before the later external-review
repairs. The [original Claude report](../../reviews/review-pr406-claude-20261120.md)
is preserved unchanged, with its [supporting probes and run records](external-review/README.md).
The owner subsequently instructed **“I agee. Fix them, then merge.”**, selecting
C406-M1 [#407](https://github.com/berkeleynerd/silver/issues/407), C406-L1
[#408](https://github.com/berkeleynerd/silver/issues/408) and C406-L2
[#409](https://github.com/berkeleynerd/silver/issues/409) for repair before merge.
Later repair validation belongs to its own record; it does not change this
historical 282 + 475 census or establish that PR #406 has merged.

The [final checkpoint](final/README.md) records these successful Linux x86-64
commands on reviewed implementation `f0a773fbcb`:

| Command | Result | Wrapper seconds |
| --- | --- | ---: |
| `dev.py build` | Both native binaries up to date; fresh managed build check | 3.196 |
| `check_lean.py --provenance` | Complete 1,035-module / 166,332-declaration audit; cached build, fresh module/axiom audit | 26.960 |
| `dev.py prove --full` | Complete 78-unit / 1,252-entity audit; 1,751 flow + 17,975 proof checks | 48.245 |

All three final commands received 22 automatic workers and recorded a 16 MiB
invoking stack. Lean used 22 threads per process. The native audit forced unit
analysis and regenerated reports with retained sessions/solver cache; the Lean
check reused the objects established by the [preparation](preparation/README.md).
No cold build, fresh-only solver measurement, independent kernel replay, macOS
validation or CI result is claimed.

The reviewed implementation is `f0a773fbcb9eea9574b037812e888029b7f970cb`; its
scripts/tests were frozen for the fresh run. Record head `cd17bc1fdf` adds review
and applicability documentation. The [independent review](../../reviews/review-proof-efficiency-373-20261120.md)
accepted the repaired implementation and the 475 retained passes' applicability.
The separately required fresh native build check and complete assurance commands
now passed as recorded above; closing review confirmed their applicability.
No compiler, library, Lean source, catalogue, sample or language change is supplied
by this tooling package.

## Original selected regression run

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
All captured scripts/tests hashes matched the original reviewed target's inputs. Discovery
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

### Explicit retained applicability for shared-auditor users (C406-L1)

The nine modules selected for the original fresh run are not the whole set of
tests that import changed shared tooling. Within the 475 retained passes,
**16 modules / 111 IDs** import `scripts.check_evidence` directly or through a
shared importer. Their reuse rests on the implementation reviewer's equivalence
judgment and the external comparison evidence, rather than a claim that they
were unaffected or all freshly rerun:

| Retained module | IDs |
| --- | ---: |
| `test_arguments` | 3 |
| `test_branching` | 7 |
| `test_command_line_greeting` | 3 |
| `test_common_expressions` | 15 |
| `test_composed_results` | 8 |
| `test_copy_values` | 8 |
| `test_greeting` | 4 |
| `test_image_reports` | 11 |
| `test_image_setup` | 8 |
| `test_main_discovery` | 2 |
| `test_named_output` | 4 |
| `test_output` | 4 |
| `test_samples` | 2 |
| `test_shared_bindings` (both historical import spellings) | 18 |
| `test_silver` | 9 |
| `test_string_assignment` | 5 |
| **Total** | **111** |

Claude compared the base and target auditors on the complete retained compiler
reports, **six real application report sets and 240 mutated variants**: **247 of
248 outcomes matched**, and all six application results matched their recorded
statistics. The one deliberately invalid caller-configuration case changed the
exception type from `EvidenceError` to `KeyError`; the reviewer found no production
caller or retained-test call site that could reach it. This is bounded supporting
evidence for the equivalence judgment, not a new universal equivalence proof.
The exact [comparison script](external-review/probes/diff_auditor.py),
[output](external-review/probes/diff_auditor.out) and input archive references are
retained with the external review.

That review also freshly passed **14 of these 111 IDs** (`test_image_setup` and
the two pure-Python classes of `test_image_reports`); **97 were not rerun** there
because they need the native toolchain. Those 14 are part of the review's later
**195-test** successful run, not additions to the original 282 fresh delivery IDs.
The earlier external attempt ended with two toolchain-dependent class setup errors;
both failed and successful review run records are retained. The original
**282 fresh + 475 retained = 757** delivery inventory remains the dated checkpoint
above; later external checks and owner-selected repair validation stay distinct.

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

[Regression archive manifest](archive-manifest.json) records compressed and original
hashes and byte counts for the initial regression records. Preparation, focused
and final packets carry their own manifests. Compression uses deterministic
mtime zero. Collection of the initial regression packet did not execute proofs or tests,
write to GitHub, commit, invoke Worca or update CLI memory. The later complete
assurance is recorded separately above; #381/#382 remain deferred. Selected evidence collector: GPT-6.1 Sol / High; independent runtime model,
effort, token and cost confirmation unavailable.
